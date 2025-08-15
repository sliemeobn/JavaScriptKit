#include <stdint.h>
#include "_CJavaScriptKit.h"
#include "WasmGlobalMacros.h"
#if __wasm32__
# ifndef __wasi__
# if __has_include("malloc.h")
#  include <malloc.h>
# endif
extern void *malloc(size_t size);
extern void free(void *ptr);
extern void *memset (void *, int, size_t);
extern void *memcpy (void *__restrict, const void *__restrict, size_t);
# else
#  include <stdlib.h>
#  include <stdbool.h>

# endif
/// The compatibility runtime library version.
/// Notes: If you change any interface of runtime library, please increment
/// this and `SwiftRuntime.version` in `./Runtime/src/index.ts`.
__attribute__((export_name("swjs_library_version")))
int swjs_library_version(void) {
    return 708;
}

__attribute__((export_name("swjs_prepare_host_function_call")))
void *swjs_prepare_host_function_call(const int argc) {
    return malloc(argc * sizeof(RawJSValue));
}

__attribute__((export_name("swjs_cleanup_host_function_call")))
void swjs_cleanup_host_function_call(void *argv_buffer) {
    free(argv_buffer);
}

# if defined(__wasi__) && !defined(__EMBEDDED_SWIFT__)
bool _call_host_function_impl(const JavaScriptHostFuncRef host_func_ref,
                              const RawJSValue *argv, const int argc,
                              const JavaScriptObjectRef callback_func);

__attribute__((export_name("swjs_call_host_function")))
bool swjs_call_host_function(const JavaScriptHostFuncRef host_func_ref,
                             const RawJSValue *argv, const int argc,
                             const JavaScriptObjectRef callback_func) {
    return _call_host_function_impl(host_func_ref, argv, argc, callback_func);
}

void _free_host_function_impl(const JavaScriptHostFuncRef host_func_ref);

__attribute__((export_name("swjs_free_host_function")))
void swjs_free_host_function(const JavaScriptHostFuncRef host_func_ref) {
    _free_host_function_impl(host_func_ref);
}

int _library_features(void);

__attribute__((export_name("swjs_library_features")))
int swjs_library_features(void) {
    return _library_features();
}
# endif

WASM_GLOBAL_DEFINE_STORAGE(_swift_js_exception, i32)
WASM_EXPORT_NAME(_swift_js_exception, _swift_js_exception)
#endif

int swjs_get_worker_thread_id_cached(void) {
    _Thread_local static int tid = 0;
    if (tid == 0) {
        tid = swjs_get_worker_thread_id();
    }
    return tid;
}
