public enum MediaPickerCropMode {
    case normal
    case custom(CroppingOverlayProvider)
}

public enum MediaPickerContinueButtonStyle {
    case normal
    case spinner
}

public protocol MediaPickerModule: class {

    func focusOnModule()
    func dismissModule()
    
    func finish()
    
    func setContinueButtonTitle(_: String)
    func setContinueButtonEnabled(_: Bool)
    func setContinueButtonVisible(_: Bool)
    func setContinueButtonStyle(_: MediaPickerContinueButtonStyle)
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    func setCropMode(_: MediaPickerCropMode)
    
    var onItemsAdd: (([MediaPickerItem], Int) -> ())? { get set }
    var onItemUpdate: ((MediaPickerItem, Int?) -> ())? { get set }
    var onItemRemove: ((MediaPickerItem, Int?) -> ())? { get set }
    var onCropFinish: (() -> ())? { get set }
    var onCropCancel: (() -> ())? { get set }
    var onContinueButtonTap: (() -> ())? { get set }

    var onFinish: (([MediaPickerItem]) -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
