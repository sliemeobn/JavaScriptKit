enum LibraryFeatures {
    static let weakRefs: Int32 = 1 << 0
}

@_expose(wasm, "swjs_library_features")
public func _library_features() -> Int32 {
    var features: Int32 = 0
#if !JAVASCRIPTKIT_WITHOUT_WEAKREFS
    features |= LibraryFeatures.weakRefs
#endif
    return features
}
