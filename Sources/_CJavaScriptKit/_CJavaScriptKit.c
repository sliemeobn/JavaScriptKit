#include "_CJavaScriptKit.h"
#if __wasm32__
#ifndef __wasi__
#if __has_include("malloc.h")
#include <malloc.h>
#endif
extern void *malloc(size_t size);
extern void free(void *ptr);
extern void *memset (void *, int, size_t);
extern void *memcpy (void *__restrict, const void *__restrict, size_t);
#else
#include <stdlib.h>
#include <stdbool.h>

#endif

__attribute__((export_name("swjs_prepare_host_function_call")))
void *swjs_prepare_host_function_call(const int argc) {
    return malloc(argc * sizeof(RawJSValue));
}

__attribute__((export_name("swjs_cleanup_host_function_call")))
void swjs_cleanup_host_function_call(void *argv_buffer) {
    free(argv_buffer);
}

// NOTE: This __wasi__ check is a hack for Embedded compatibility (assuming that if __wasi__ is defined, we are not building for Embedded)
// cdecls don't work in Embedded, but @_expose(wasm) can be used with Swift >=6.0
// the previously used `#if __Embedded` did not play well with SwiftPM (defines needed to be on every target up the chain)
#ifdef __wasi__
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

int swjs_get_worker_thread_id_cached(void) {
    _Thread_local static int tid = 0;
    if (tid == 0) {
        tid = swjs_get_worker_thread_id();
    }
    return tid;
}
#endif
#endif
