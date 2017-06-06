public enum MediaPickerCropMode {
    case normal
    case custom(CroppingOverlayProvider)
}

public protocol MediaPickerModule: class {

    func focusOnModule()
    func dismissModule()
    
    func setContinueButtonTitle(_: String)
    func setContinueButtonEnabled(_: Bool)
    func setContinueButtonVisible(_: Bool)
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    func setCropMode(_: MediaPickerCropMode)
    
    var onItemsAdd: (([MediaPickerItem]) -> ())? { get set }
    var onItemUpdate: ((MediaPickerItem) -> ())? { get set }
    var onItemRemove: ((MediaPickerItem) -> ())? { get set }

    var onFinish: (([MediaPickerItem]) -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
