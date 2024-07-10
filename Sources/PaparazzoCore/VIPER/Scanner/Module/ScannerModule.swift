import Foundation

public protocol ScannerModule: AnyObject {

    func focusOnModule()
    func dismissModule()
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ())
    func finish()
    
    func showInfoMessage(_ message: String, timeout: TimeInterval)
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)

    var onFinish: (() -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
