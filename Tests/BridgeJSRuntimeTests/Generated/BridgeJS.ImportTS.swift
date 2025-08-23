// NOTICE: This is auto-generated code by BridgeJS from JavaScriptKit,
// DO NOT EDIT.
//
// To update this file, just rebuild your project or run
// `swift package bridge-js`.

@_spi(BridgeJS) import JavaScriptKit

func jsRoundTripVoid() throws(JSException) -> Void {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsRoundTripVoid")
    func bjs_jsRoundTripVoid() -> Void
    #else
    func bjs_jsRoundTripVoid() -> Void {
        fatalError("Only available on WebAssembly")
    }
    #endif
    bjs_jsRoundTripVoid()
    if let error = _swift_js_take_exception() {
        throw error
    }
}

func jsRoundTripNumber(_ v: Double) throws(JSException) -> Double {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsRoundTripNumber")
    func bjs_jsRoundTripNumber(_ v: Float64) -> Float64
    #else
    func bjs_jsRoundTripNumber(_ v: Float64) -> Float64 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_jsRoundTripNumber(v)
    if let error = _swift_js_take_exception() {
        throw error
    }
    return Double(ret)
}

func jsRoundTripBool(_ v: Bool) throws(JSException) -> Bool {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsRoundTripBool")
    func bjs_jsRoundTripBool(_ v: Int32) -> Int32
    #else
    func bjs_jsRoundTripBool(_ v: Int32) -> Int32 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_jsRoundTripBool(v.bridgeJSLowerParameter())
    if let error = _swift_js_take_exception() {
        throw error
    }
    return Bool.bridgeJSLiftReturn(ret)
}

func jsRoundTripString(_ v: String) throws(JSException) -> String {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsRoundTripString")
    func bjs_jsRoundTripString(_ v: Int32) -> Int32
    #else
    func bjs_jsRoundTripString(_ v: Int32) -> Int32 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_jsRoundTripString(v.bridgeJSLowerParameter())
    if let error = _swift_js_take_exception() {
        throw error
    }
    return String.bridgeJSLiftReturn(ret)
}

func jsThrowOrVoid(_ shouldThrow: Bool) throws(JSException) -> Void {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsThrowOrVoid")
    func bjs_jsThrowOrVoid(_ shouldThrow: Int32) -> Void
    #else
    func bjs_jsThrowOrVoid(_ shouldThrow: Int32) -> Void {
        fatalError("Only available on WebAssembly")
    }
    #endif
    bjs_jsThrowOrVoid(shouldThrow.bridgeJSLowerParameter())
    if let error = _swift_js_take_exception() {
        throw error
    }
}

func jsThrowOrNumber(_ shouldThrow: Bool) throws(JSException) -> Double {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsThrowOrNumber")
    func bjs_jsThrowOrNumber(_ shouldThrow: Int32) -> Float64
    #else
    func bjs_jsThrowOrNumber(_ shouldThrow: Int32) -> Float64 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_jsThrowOrNumber(shouldThrow.bridgeJSLowerParameter())
    if let error = _swift_js_take_exception() {
        throw error
    }
    return Double(ret)
}

func jsThrowOrBool(_ shouldThrow: Bool) throws(JSException) -> Bool {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsThrowOrBool")
    func bjs_jsThrowOrBool(_ shouldThrow: Int32) -> Int32
    #else
    func bjs_jsThrowOrBool(_ shouldThrow: Int32) -> Int32 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_jsThrowOrBool(shouldThrow.bridgeJSLowerParameter())
    if let error = _swift_js_take_exception() {
        throw error
    }
    return Bool.bridgeJSLiftReturn(ret)
}

func jsThrowOrString(_ shouldThrow: Bool) throws(JSException) -> String {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_jsThrowOrString")
    func bjs_jsThrowOrString(_ shouldThrow: Int32) -> Int32
    #else
    func bjs_jsThrowOrString(_ shouldThrow: Int32) -> Int32 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_jsThrowOrString(shouldThrow.bridgeJSLowerParameter())
    if let error = _swift_js_take_exception() {
        throw error
    }
    return String.bridgeJSLiftReturn(ret)
}

func runAsyncWorks() throws(JSException) -> JSPromise {
    #if arch(wasm32)
    @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_runAsyncWorks")
    func bjs_runAsyncWorks() -> Int32
    #else
    func bjs_runAsyncWorks() -> Int32 {
        fatalError("Only available on WebAssembly")
    }
    #endif
    let ret = bjs_runAsyncWorks()
    if let error = _swift_js_take_exception() {
        throw error
    }
    return JSPromise(takingThis: ret)
}

struct JsGreeter {
    let this: JSObject

    init(this: JSObject) {
        self.this = this
    }

    init(takingThis this: Int32) {
        self.this = JSObject(id: UInt32(bitPattern: this))
    }

    init(_ name: String, _ prefix: String) throws(JSException) {
        #if arch(wasm32)
        @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_JsGreeter_init")
        func bjs_JsGreeter_init(_ name: Int32, _ prefix: Int32) -> Int32
        #else
        func bjs_JsGreeter_init(_ name: Int32, _ prefix: Int32) -> Int32 {
            fatalError("Only available on WebAssembly")
        }
        #endif
        let ret = bjs_JsGreeter_init(name.bridgeJSLowerParameter(), prefix.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
        self.this = JSObject(id: UInt32(bitPattern: ret))
    }

    var name: String {
        get throws(JSException) {
            #if arch(wasm32)
            @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_JsGreeter_name_get")
            func bjs_JsGreeter_name_get(_ self: Int32) -> Int32
            #else
            func bjs_JsGreeter_name_get(_ self: Int32) -> Int32 {
                fatalError("Only available on WebAssembly")
            }
            #endif
            let ret = bjs_JsGreeter_name_get(self.this.bridgeJSLowerParameter())
            if let error = _swift_js_take_exception() {
                throw error
            }
            return String.bridgeJSLiftReturn(ret)
        }
    }

    func setName(_ newValue: String) throws(JSException) -> Void {
        #if arch(wasm32)
        @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_JsGreeter_name_set")
        func bjs_JsGreeter_name_set(_ self: Int32, _ newValue: Int32) -> Void
        #else
        func bjs_JsGreeter_name_set(_ self: Int32, _ newValue: Int32) -> Void {
            fatalError("Only available on WebAssembly")
        }
        #endif
        bjs_JsGreeter_name_set(self.this.bridgeJSLowerParameter(), newValue.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
    }

    var prefix: String {
        get throws(JSException) {
            #if arch(wasm32)
            @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_JsGreeter_prefix_get")
            func bjs_JsGreeter_prefix_get(_ self: Int32) -> Int32
            #else
            func bjs_JsGreeter_prefix_get(_ self: Int32) -> Int32 {
                fatalError("Only available on WebAssembly")
            }
            #endif
            let ret = bjs_JsGreeter_prefix_get(self.this.bridgeJSLowerParameter())
            if let error = _swift_js_take_exception() {
                throw error
            }
            return String.bridgeJSLiftReturn(ret)
        }
    }

    func greet() throws(JSException) -> String {
        #if arch(wasm32)
        @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_JsGreeter_greet")
        func bjs_JsGreeter_greet(_ self: Int32) -> Int32
        #else
        func bjs_JsGreeter_greet(_ self: Int32) -> Int32 {
            fatalError("Only available on WebAssembly")
        }
        #endif
        let ret = bjs_JsGreeter_greet(self.this.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
        return String.bridgeJSLiftReturn(ret)
    }

    func changeName(_ name: String) throws(JSException) -> Void {
        #if arch(wasm32)
        @_extern(wasm, module: "BridgeJSRuntimeTests", name: "bjs_JsGreeter_changeName")
        func bjs_JsGreeter_changeName(_ self: Int32, _ name: Int32) -> Void
        #else
        func bjs_JsGreeter_changeName(_ self: Int32, _ name: Int32) -> Void {
            fatalError("Only available on WebAssembly")
        }
        #endif
        bjs_JsGreeter_changeName(self.this.bridgeJSLowerParameter(), name.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
    }

}