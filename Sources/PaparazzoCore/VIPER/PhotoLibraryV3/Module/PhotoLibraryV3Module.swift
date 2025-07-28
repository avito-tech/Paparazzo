public protocol PhotoLibraryV3Module: PaparazzoPickerModule {
    var onCameraV3Show: (() -> ())? { get set }
}
