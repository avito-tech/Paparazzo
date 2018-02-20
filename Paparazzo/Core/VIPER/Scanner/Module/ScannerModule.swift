public protocol ScannerModule: class {

    func focusOnModule()
    func dismissModule()
    
    func finish()
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    var onItemAdd: ((MediaPickerItem) -> ())? { get set }

    var onFinish: ((MediaPickerItem?) -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
