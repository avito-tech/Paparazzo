import ImageSource

protocol ScannerRouter: AnyObject {
    
    func focusOnCurrentModule()
    func dismissCurrentModule()
}
