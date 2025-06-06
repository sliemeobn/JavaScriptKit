import JavaScriptKit
import _CJavaScriptEventLoop
import _CJavaScriptKit

// NOTE: `@available` annotations are semantically wrong, but they make it easier to develop applications targeting WebAssembly in Xcode.

#if compiler(>=5.5)

/// Singleton type responsible for integrating JavaScript event loop as a Swift concurrency executor, conforming to
/// `SerialExecutor` protocol from the standard library. To utilize it:
///
/// 1. Make sure that your target depends on `JavaScriptEventLoop` in your `Packages.swift`:
///
/// ```swift
/// .target(
///    name: "JavaScriptKitExample",
///    dependencies: [
///        "JavaScriptKit",
///        .product(name: "JavaScriptEventLoop", package: "JavaScriptKit")
///    ]
/// )
/// ```
///
/// 2. Add an explicit import in the code that executes **before* you start using `await` and/or `Task`
/// APIs (most likely in `main.swift`):
///
/// ```swift
/// import JavaScriptEventLoop
/// ```
///
/// 3. Run this function **before* you start using `await` and/or `Task` APIs (again, most likely in
/// `main.swift`):
///
/// ```swift
/// JavaScriptEventLoop.installGlobalExecutor()
/// ```
@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
public final class JavaScriptEventLoop: SerialExecutor, @unchecked Sendable {

    /// A function that queues a given closure as a microtask into JavaScript event loop.
    /// See also: https://developer.mozilla.org/en-US/docs/Web/API/HTML_DOM_API/Microtask_guide
    public var queueMicrotask: (@escaping () -> Void) -> Void
    /// A function that invokes a given closure after a specified number of milliseconds.
    public var setTimeout: (Double, @escaping () -> Void) -> Void

    /// A mutable state to manage internal job queue
    /// Note that this should be guarded atomically when supporting multi-threaded environment.
    var queueState = QueueState()

    private init(
        queueTask: @escaping (@escaping () -> Void) -> Void,
        setTimeout: @escaping (Double, @escaping () -> Void) -> Void
    ) {
        self.queueMicrotask = queueTask
        self.setTimeout = setTimeout
    }

    /// A per-thread singleton instance of the Executor
    public static var shared: JavaScriptEventLoop {
        return _shared
    }

    #if compiler(>=6.1) && _runtime(_multithreaded)
    // In multi-threaded environment, we have an event loop executor per
    // thread (per Web Worker). A job enqueued in one thread should be
    // executed in the same thread under this global executor.
    private static var _shared: JavaScriptEventLoop {
        if let tls = swjs_thread_local_event_loop {
            let eventLoop = Unmanaged<JavaScriptEventLoop>.fromOpaque(tls).takeUnretainedValue()
            return eventLoop
        }
        let eventLoop = create()
        swjs_thread_local_event_loop = Unmanaged.passRetained(eventLoop).toOpaque()
        return eventLoop
    }
    #else
    private static let _shared: JavaScriptEventLoop = create()
    #endif

    private static func create() -> JavaScriptEventLoop {
        let promise = JSPromise(resolver: { resolver -> Void in
            resolver(.success(.undefined))
        })
        let setTimeout = JSObject.global.setTimeout.function!
        let eventLoop = JavaScriptEventLoop(
            queueTask: { job in
                // TODO(katei): Should prefer `queueMicrotask` if available?
                // We should measure if there is performance advantage.
                promise.then { _ in
                    job()
                    return JSValue.undefined
                }
            },
            setTimeout: { delay, job in
                setTimeout(
                    JSOneshotClosure { _ in
                        job()
                        return JSValue.undefined
                    },
                    delay
                )
            }
        )
        return eventLoop
    }

    @MainActor private static var didInstallGlobalExecutor = false

    /// Set JavaScript event loop based executor to be the global executor
    /// Note that this should be called before any of the jobs are created.
    /// This installation step will be unnecessary after custom executor are
    /// introduced officially. See also [a draft proposal for custom
    /// executors](https://github.com/rjmccall/swift-evolution/blob/custom-executors/proposals/0000-custom-executors.md#the-default-global-concurrent-executor)
    public static func installGlobalExecutor() {
        MainActor.assumeIsolated {
            Self.installGlobalExecutorIsolated()
        }
    }

    @MainActor private static func installGlobalExecutorIsolated() {
        guard !didInstallGlobalExecutor else { return }

        #if compiler(>=5.9)
        typealias swift_task_asyncMainDrainQueue_hook_Fn = @convention(thin) (
            swift_task_asyncMainDrainQueue_original, swift_task_asyncMainDrainQueue_override
        ) -> Void
        let swift_task_asyncMainDrainQueue_hook_impl: swift_task_asyncMainDrainQueue_hook_Fn = { _, _ in
            swjs_unsafe_event_loop_yield()
        }
        swift_task_asyncMainDrainQueue_hook = unsafeBitCast(
            swift_task_asyncMainDrainQueue_hook_impl,
            to: UnsafeMutableRawPointer?.self
        )
        #endif

        typealias swift_task_enqueueGlobal_hook_Fn = @convention(thin) (UnownedJob, swift_task_enqueueGlobal_original)
            -> Void
        let swift_task_enqueueGlobal_hook_impl: swift_task_enqueueGlobal_hook_Fn = { job, original in
            JavaScriptEventLoop.shared.unsafeEnqueue(job)
        }
        swift_task_enqueueGlobal_hook = unsafeBitCast(
            swift_task_enqueueGlobal_hook_impl,
            to: UnsafeMutableRawPointer?.self
        )

        typealias swift_task_enqueueGlobalWithDelay_hook_Fn = @convention(thin) (
            UInt64, UnownedJob, swift_task_enqueueGlobalWithDelay_original
        ) -> Void
        let swift_task_enqueueGlobalWithDelay_hook_impl: swift_task_enqueueGlobalWithDelay_hook_Fn = {
            delay,
            job,
            original in
            JavaScriptEventLoop.shared.enqueue(job, withDelay: delay)
        }
        swift_task_enqueueGlobalWithDelay_hook = unsafeBitCast(
            swift_task_enqueueGlobalWithDelay_hook_impl,
            to: UnsafeMutableRawPointer?.self
        )

        #if compiler(>=5.7)
        typealias swift_task_enqueueGlobalWithDeadline_hook_Fn = @convention(thin) (
            Int64, Int64, Int64, Int64, Int32, UnownedJob, swift_task_enqueueGlobalWithDelay_original
        ) -> Void
        let swift_task_enqueueGlobalWithDeadline_hook_impl: swift_task_enqueueGlobalWithDeadline_hook_Fn = {
            sec,
            nsec,
            tsec,
            tnsec,
            clock,
            job,
            original in
            JavaScriptEventLoop.shared.enqueue(job, withDelay: sec, nsec, tsec, tnsec, clock)
        }
        swift_task_enqueueGlobalWithDeadline_hook = unsafeBitCast(
            swift_task_enqueueGlobalWithDeadline_hook_impl,
            to: UnsafeMutableRawPointer?.self
        )
        #endif

        typealias swift_task_enqueueMainExecutor_hook_Fn = @convention(thin) (
            UnownedJob, swift_task_enqueueMainExecutor_original
        ) -> Void
        let swift_task_enqueueMainExecutor_hook_impl: swift_task_enqueueMainExecutor_hook_Fn = { job, original in
            JavaScriptEventLoop.shared.unsafeEnqueue(job)
        }
        swift_task_enqueueMainExecutor_hook = unsafeBitCast(
            swift_task_enqueueMainExecutor_hook_impl,
            to: UnsafeMutableRawPointer?.self
        )

        didInstallGlobalExecutor = true
    }

    private func enqueue(_ job: UnownedJob, withDelay nanoseconds: UInt64) {
        let milliseconds = nanoseconds / 1_000_000
        setTimeout(
            Double(milliseconds),
            {
                #if compiler(>=5.9)
                job.runSynchronously(on: self.asUnownedSerialExecutor())
                #else
                job._runSynchronously(on: self.asUnownedSerialExecutor())
                #endif
            }
        )
    }

    private func unsafeEnqueue(_ job: UnownedJob) {
        insertJobQueue(job: job)
    }

    #if compiler(>=5.9)
    @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
    public func enqueue(_ job: consuming ExecutorJob) {
        // NOTE: Converting a `ExecutorJob` to an ``UnownedJob`` and invoking
        // ``UnownedJob/runSynchronously(_:)` on it multiple times is undefined behavior.
        unsafeEnqueue(UnownedJob(job))
    }
    #else
    public func enqueue(_ job: UnownedJob) {
        unsafeEnqueue(job)
    }
    #endif

    public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        return UnownedSerialExecutor(ordinary: self)
    }
}

#if compiler(>=5.7)
/// Taken from https://github.com/apple/swift/blob/d375c972f12128ec6055ed5f5337bfcae3ec67d8/stdlib/public/Concurrency/Clock.swift#L84-L88
@_silgen_name("swift_get_time")
internal func swift_get_time(
    _ seconds: UnsafeMutablePointer<Int64>,
    _ nanoseconds: UnsafeMutablePointer<Int64>,
    _ clock: CInt
)

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
extension JavaScriptEventLoop {
    fileprivate func enqueue(
        _ job: UnownedJob,
        withDelay seconds: Int64,
        _ nanoseconds: Int64,
        _ toleranceSec: Int64,
        _ toleranceNSec: Int64,
        _ clock: Int32
    ) {
        var nowSec: Int64 = 0
        var nowNSec: Int64 = 0
        swift_get_time(&nowSec, &nowNSec, clock)
        let delayNanosec = (seconds - nowSec) * 1_000_000_000 + (nanoseconds - nowNSec)
        enqueue(job, withDelay: delayNanosec <= 0 ? 0 : UInt64(delayNanosec))
    }
}
#endif

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension JSPromise {
    /// Wait for the promise to complete, returning (or throwing) its result.
    public var value: JSValue {
        get async throws {
            try await withUnsafeThrowingContinuation { [self] continuation in
                self.then(
                    success: {
                        continuation.resume(returning: $0)
                        return JSValue.undefined
                    },
                    failure: {
                        continuation.resume(throwing: JSException($0))
                        return JSValue.undefined
                    }
                )
            }
        }
    }

    /// Wait for the promise to complete, returning its result or exception as a Result.
    ///
    /// - Note: Calling this function does not switch from the caller's isolation domain.
    public func value(isolation: isolated (any Actor)? = #isolation) async throws -> JSValue {
        try await withUnsafeThrowingContinuation(isolation: isolation) { [self] continuation in
            self.then(
                success: {
                    continuation.resume(returning: $0)
                    return JSValue.undefined
                },
                failure: {
                    continuation.resume(throwing: JSException($0))
                    return JSValue.undefined
                }
            )
        }
    }

    /// Wait for the promise to complete, returning its result or exception as a Result.
    public var result: JSPromise.Result {
        get async {
            await withUnsafeContinuation { [self] continuation in
                self.then(
                    success: {
                        continuation.resume(returning: .success($0))
                        return JSValue.undefined
                    },
                    failure: {
                        continuation.resume(returning: .failure($0))
                        return JSValue.undefined
                    }
                )
            }
        }
    }
}

#endif
