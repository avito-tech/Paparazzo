public protocol PhotoLibraryUITheme: AccessDeniedViewTheme {
    
    var photoLibraryTitleFont: UIFont { get }
    var photoLibraryAlbumsDisclosureIcon: UIImage? { get }
    
    var photoLibraryItemSelectionColor: UIColor { get }
    var photoCellBackgroundColor: UIColor { get }
    
    var iCloudIcon: UIImage? { get }
    var photoLibraryDiscardButtonIcon: UIImage? { get }
    var photoLibraryConfirmButtonIcon: UIImage? { get }
    var photoLibraryAlbumCellFont: UIFont { get }
}
