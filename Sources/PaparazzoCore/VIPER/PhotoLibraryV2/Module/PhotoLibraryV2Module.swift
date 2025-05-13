public protocol PhotoLibraryV2Module: PaparazzoPickerModule {
    var onCameraV3Show: (() -> ())? { get set }
}
