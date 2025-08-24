// NOTICE: This is auto-generated code by BridgeJS from JavaScriptKit,
// DO NOT EDIT.
//
// To update this file, just rebuild your project or run
// `swift package bridge-js`.

@_spi(BridgeJS) import JavaScriptKit

struct Greeter: _JSBridgedClass {
    let jsObject: JSObject

    init(unsafelyWrapping jsObject: JSObject) {
        self.jsObject = jsObject
    }

    init(_ name: String) throws(JSException) {
        #if arch(wasm32)
        @_extern(wasm, module: "Check", name: "bjs_Greeter_init")
        func bjs_Greeter_init(_ name: Int32) -> Int32
        #else
        func bjs_Greeter_init(_ name: Int32) -> Int32 {
            fatalError("Only available on WebAssembly")
        }
        #endif
        let ret = bjs_Greeter_init(name.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
        self.jsObject = JSObject(id: UInt32(bitPattern: ret))
    }

    var name: String {
        get throws(JSException) {
            #if arch(wasm32)
            @_extern(wasm, module: "Check", name: "bjs_Greeter_name_get")
            func bjs_Greeter_name_get(_ self: Int32) -> Int32
            #else
            func bjs_Greeter_name_get(_ self: Int32) -> Int32 {
                fatalError("Only available on WebAssembly")
            }
            #endif
            let ret = bjs_Greeter_name_get(self.bridgeJSLowerParameter())
            if let error = _swift_js_take_exception() {
                throw error
            }
            return String.bridgeJSLiftReturn(ret)
        }
    }

    func setName(_ newValue: String) throws(JSException) -> Void {
        #if arch(wasm32)
        @_extern(wasm, module: "Check", name: "bjs_Greeter_name_set")
        func bjs_Greeter_name_set(_ self: Int32, _ newValue: Int32) -> Void
        #else
        func bjs_Greeter_name_set(_ self: Int32, _ newValue: Int32) -> Void {
            fatalError("Only available on WebAssembly")
        }
        #endif
        bjs_Greeter_name_set(self.bridgeJSLowerParameter(), newValue.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
    }

    var age: Double {
        get throws(JSException) {
            #if arch(wasm32)
            @_extern(wasm, module: "Check", name: "bjs_Greeter_age_get")
            func bjs_Greeter_age_get(_ self: Int32) -> Float64
            #else
            func bjs_Greeter_age_get(_ self: Int32) -> Float64 {
                fatalError("Only available on WebAssembly")
            }
            #endif
            let ret = bjs_Greeter_age_get(self.bridgeJSLowerParameter())
            if let error = _swift_js_take_exception() {
                throw error
            }
            return Double.bridgeJSLiftReturn(ret)
        }
    }

    func greet() throws(JSException) -> String {
        #if arch(wasm32)
        @_extern(wasm, module: "Check", name: "bjs_Greeter_greet")
        func bjs_Greeter_greet(_ self: Int32) -> Int32
        #else
        func bjs_Greeter_greet(_ self: Int32) -> Int32 {
            fatalError("Only available on WebAssembly")
        }
        #endif
        let ret = bjs_Greeter_greet(self.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
        return String.bridgeJSLiftReturn(ret)
    }

    func changeName(_ name: String) throws(JSException) -> Void {
        #if arch(wasm32)
        @_extern(wasm, module: "Check", name: "bjs_Greeter_changeName")
        func bjs_Greeter_changeName(_ self: Int32, _ name: Int32) -> Void
        #else
        func bjs_Greeter_changeName(_ self: Int32, _ name: Int32) -> Void {
            fatalError("Only available on WebAssembly")
        }
        #endif
        bjs_Greeter_changeName(self.bridgeJSLowerParameter(), name.bridgeJSLowerParameter())
        if let error = _swift_js_take_exception() {
            throw error
        }
    }

}