public protocol MediaPickerModule: class {

    func focusOnModule()
    func dismissModule()
    
    func setContinueButtonTitle(_: String)
    func setContinueButtonEnabled(_: Bool)
    func setContinueButtonVisible(_: Bool)
    
    var onItemsAdd: (([MediaPickerItem]) -> ())? { get set }
    var onItemUpdate: ((MediaPickerItem) -> ())? { get set }
    var onItemRemove: ((MediaPickerItem) -> ())? { get set }

    var onFinish: (([MediaPickerItem]) -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
