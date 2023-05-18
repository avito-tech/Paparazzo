enum CameraV3ModuleResult {
    case finished
    case cancelled
}

protocol CameraV3Module: AnyObject {
    var configureMediaPicker: ((MediaPickerModule) -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    var onFinish: ((CameraV3Module, CameraV3ModuleResult) -> ())? { get set }
    
    func focusOnCurrentModule()
}
