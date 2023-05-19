public protocol PhotoLibraryV2Module: PaparazzoPickerModule {
    var onNewCameraShow: (() -> ())? { get set }
    var onCameraV3Show: (() -> ())? { get set }
}
