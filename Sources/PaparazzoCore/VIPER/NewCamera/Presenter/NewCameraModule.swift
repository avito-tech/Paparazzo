enum NewCameraModuleResult {
    case finished
    case cancelled
}

protocol NewCameraModule: AnyObject {
    var onFinish: ((NewCameraModule, NewCameraModuleResult) -> ())? { get set }
    var configureMediaPicker: ((MediaPickerModule) -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    func focusOnModule()
}
