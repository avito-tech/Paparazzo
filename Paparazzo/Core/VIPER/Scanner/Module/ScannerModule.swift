public protocol ScannerModule: class {

    func focusOnModule()
    func dismissModule()
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ())
    func finish()
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)

    var onFinish: (() -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
