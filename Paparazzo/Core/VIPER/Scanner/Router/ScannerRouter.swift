import ImageSource

protocol ScannerRouter: class {
    
    func focusOnCurrentModule()
    func dismissCurrentModule()
}
