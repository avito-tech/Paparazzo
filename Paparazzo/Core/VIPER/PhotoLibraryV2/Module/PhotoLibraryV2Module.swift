public protocol PhotoLibraryV2Module: PaparazzoPickerModule {
    var onNewCameraShow: (() -> ())? { get set }
}
