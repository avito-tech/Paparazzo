public protocol PhotoLibraryV2UITheme: AccessDeniedViewTheme {
    
    var photoLibraryTitleFont: UIFont { get }
    var photoLibraryAlbumsDisclosureIcon: UIImage? { get }
    
    var photoLibraryItemSelectionColor: UIColor { get }
    var photoCellBackgroundColor: UIColor { get }
    
    var iCloudIcon: UIImage? { get }
    var continueButtonTitleColor: UIColor { get }
    var continueButtonTitleHighlightedColor: UIColor { get }
    var continueButtonTitleFont: UIFont { get }
    var photoLibraryAlbumCellFont: UIFont { get }
    var photoLibraryPlaceholderFont: UIFont { get }
    var photoLibraryPlaceholderColor: UIColor { get }
    var libraryBottomContinueButtonBackgroundColor: UIColor { get }
    var libraryBottomContinueButtonTitleColor: UIColor { get }
    var libraryBottomContinueButtonFont: UIFont { get }
    
    var closeIcon: UIImage? { get }
    
    var cameraIcon: UIImage? { get }
}
