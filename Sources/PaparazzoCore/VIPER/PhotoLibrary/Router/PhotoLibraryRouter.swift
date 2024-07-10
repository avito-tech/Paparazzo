protocol PhotoLibraryRouter: AnyObject {
    func dismissCurrentModule()
    
    @available(iOS 14, *)
    func showLimitedAccessAlert()
}
