public protocol PhotoLibraryUITheme: AccessDeniedViewTheme {

    var photoLibraryDoneButtonFont: UIFont { get }
    
    var photoLibraryItemSelectionColor: UIColor { get }
    var photoCellBackgroundColor: UIColor { get }
    
    var iCloudIcon: UIImage? { get }
    var photoLibraryDiscardButtonIcon: UIImage? { get }
    var photoLibraryConfirmButtonIcon: UIImage? { get }
}
