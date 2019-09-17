enum NewCameraModuleResult {
    case finished
    case cancelled
}

protocol NewCameraModule: class {
    var onFinish: ((NewCameraModule, NewCameraModuleResult) -> ())? { get set }
    var configureMediaPicker: ((MediaPickerModule) -> ())? { get set }
    func focusOnModule()
}
