enum MedicalBookCameraModuleResult {
    case finished
    case cancelled
}

protocol MedicalBookCameraModule: AnyObject {
    var configureMediaPicker: ((MediaPickerModule) -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    var onFinish: ((MedicalBookCameraModule, MedicalBookCameraModuleResult) -> ())? { get set }
    
    func focusOnCurrentModule()
}
