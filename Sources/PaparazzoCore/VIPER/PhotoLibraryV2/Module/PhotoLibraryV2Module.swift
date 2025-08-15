@available(*, deprecated, message: "Use PhotoLibraryV3Module instead")
public protocol PhotoLibraryV2Module: PaparazzoPickerModule {
    var onCameraV3Show: (() -> ())? { get set }
}
