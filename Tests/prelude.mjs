// @ts-check

/** @type {import('../.build/plugins/PackageToJS/outputs/PackageTests/test.d.ts').SetupOptionsFn} */
export async function setupOptions(options, context) {
    Error.stackTraceLimit = 100;
    setupTestGlobals(globalThis);
    return {
        ...options,
        imports: {
            "jsRoundTripVoid": () => {
                return;
            },
            "jsRoundTripNumber": (v) => {
                return v;
            },
            "jsRoundTripBool": (v) => {
                return v;
            },
            "jsRoundTripString": (v) => {
                return v;
            },
            "jsThrowOrVoid": (shouldThrow) => {
                if (shouldThrow) {
                    throw new Error("TestError");
                }
            },
            "jsThrowOrNumber": (shouldThrow) => {
                if (shouldThrow) {
                    throw new Error("TestError");
                }
                return 1;
            },
            "jsThrowOrBool": (shouldThrow) => {
                if (shouldThrow) {
                    throw new Error("TestError");
                }
                return true;
            },
            "jsThrowOrString": (shouldThrow) => {
                if (shouldThrow) {
                    throw new Error("TestError");
                }
                return "Hello, world!";
            },
            JsGreeter: class {
                /**
                 * @param {string} name
                 * @param {string} prefix
                 */
                constructor(name, prefix) {
                    this.name = name;
                    this.prefix = prefix;
                }
                greet() {
                    return `${this.prefix}, ${this.name}!`;
                }
                /** @param {string} name */
                changeName(name) {
                    this.name = name;
                }
            }
        },
        addToCoreImports(importObject, importsContext) {
            const { getInstance, getExports } = importsContext;
            options.addToCoreImports?.(importObject, importsContext);
            importObject["JavaScriptEventLoopTestSupportTests"] = {
                "isMainThread": () => context.isMainThread,
            }
            const bridgeJSRuntimeTests = importObject["BridgeJSRuntimeTests"] || {};
            bridgeJSRuntimeTests["runJsWorks"] = () => {
                return BridgeJSRuntimeTests_runJsWorks(getInstance(), getExports());
            }
            importObject["BridgeJSRuntimeTests"] = bridgeJSRuntimeTests;
        }
    }
}

import assert from "node:assert";

/** @param {import('./../.build/plugins/PackageToJS/outputs/PackageTests/bridge-js.d.ts').Exports} exports */
function BridgeJSRuntimeTests_runJsWorks(instance, exports) {
    exports.roundTripVoid();
    for (const v of [0, 1, -1, 2147483647, -2147483648]) {
        assert.equal(exports.roundTripInt(v), v);
    }
    for (const v of [
        0.0, 1.0, -1.0,
        NaN,
        Infinity,
        /* .pi */ 3.141592502593994,
        /* .greatestFiniteMagnitude */ 3.4028234663852886e+38,
        /* .leastNonzeroMagnitude */ 1.401298464324817e-45
    ]) {
        assert.equal(exports.roundTripFloat(v), v);
    }
    for (const v of [
        0.0, 1.0, -1.0,
        NaN,
        Infinity,
        /* .pi */ 3.141592502593994,
        /* .greatestFiniteMagnitude */ 3.4028234663852886e+38,
        /* .leastNonzeroMagnitude */ 1.401298464324817e-45
    ]) {
        assert.equal(exports.roundTripDouble(v), v);
    }
    for (const v of [true, false]) {
        assert.equal(exports.roundTripBool(v), v);
    }
    for (const v of [
        "Hello, world!",
        "😄",
        "こんにちは",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    ]) {
        assert.equal(exports.roundTripString(v), v);
    }

    const g = new exports.Greeter("John");
    assert.equal(g.greet(), "Hello, John!");
    g.changeName("Jane");
    assert.equal(g.greet(), "Hello, Jane!");
    exports.takeGreeter(g, "Jay");
    assert.equal(g.greet(), "Hello, Jay!");

    const g2 = exports.roundTripSwiftHeapObject(g)
    assert.equal(g2.greet(), "Hello, Jay!");
    g2.release();

    g.release();

    // Test class without @JS init constructor
    const calc = exports.createCalculator();
    assert.equal(calc.square(5), 25);
    assert.equal(calc.add(3, 4), 7);
    assert.equal(exports.useCalculator(calc, 3, 10), 19); // 3^2 + 10 = 19
    
    calc.release();

    const anyObject = {};
    assert.equal(exports.roundTripJSObject(anyObject), anyObject);

    try {
        exports.throwsSwiftError(true);
        assert.fail("Expected error");
    } catch (error) {
        assert.equal(error.message, "TestError", error);
    }

    try {
        exports.throwsSwiftError(false);
    } catch (error) {
        assert.fail("Expected no error");
    }
}

function setupTestGlobals(global) {
    global.globalObject1 = {
        prop_1: {
            nested_prop: 1,
        },
        prop_2: 2,
        prop_3: true,
        prop_4: [3, 4, "str_elm_1", null, undefined, 5],
        prop_5: {
            func1: function () {
                return;
            },
            func2: function () {
                return 1;
            },
            func3: function (n) {
                return n * 2;
            },
            func4: function (a, b, c) {
                return a + b + c;
            },
            func5: function (x) {
                return "Hello, " + x;
            },
            func6: function (c, a, b) {
                if (c) {
                    return a;
                } else {
                    return b;
                }
            },
        },
        prop_6: {
            call_host_1: () => {
                return global.globalObject1.prop_6.host_func_1();
            },
        },
        prop_7: 3.14,
        prop_8: [0, , 2, 3, , , 6],
        eval_closure: function (fn) {
            return fn(arguments[1]);
        },
        observable_obj: {
            set_called: false,
            target: new Proxy(
                {
                    nested: {},
                },
                {
                    set(target, key, value) {
                        global.globalObject1.observable_obj.set_called = true;
                        target[key] = value;
                        return true;
                    },
                }
            ),
        },
    };

    global.Animal = function (name, age, isCat) {
        if (age < 0) {
            throw new Error("Invalid age " + age);
        }
        this.name = name;
        this.age = age;
        this.bark = () => {
            return isCat ? "nyan" : "wan";
        };
        this.isCat = isCat;
        this.getIsCat = function () {
            return this.isCat;
        };
        this.setName = function (name) {
            this.name = name;
        };
    };

    global.callThrowingClosure = (c) => {
        try {
            c();
        } catch (error) {
            return error;
        }
    };

    global.objectDecodingTest = {
        obj: {},
        fn: () => { },
        sym: Symbol("s"),
        bi: BigInt(3)
    };
}
