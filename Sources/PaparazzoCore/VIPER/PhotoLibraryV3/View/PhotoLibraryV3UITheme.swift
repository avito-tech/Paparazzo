import UIKit

public protocol PhotoLibraryV3UITheme: AccessDeniedViewTheme {
    
    var photoLibraryAlbumsTableViewCellBackgroundColor: UIColor { get }
    var photoLibraryAlbumsTableViewBackgroundColor: UIColor { get }
    var photoLibraryCollectionBackgroundColor: UIColor { get }
    var photoLibraryAlbumsCellDefaultLabelColor: UIColor { get }
    var photoLibraryAlbumsCellSelectedLabelColor: UIColor { get }
    
    var photoLibraryTitleFont: UIFont { get }
    var photoLibraryTitleColor: UIColor { get }
    var photoLibraryAlbumsDisclosureIcon: UIImage? { get }
    var photoLibraryAlbumsDisclosureIconColor: UIColor { get }
    
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
    var libraryBottomContinueButtonCornerRadius: CGFloat { get }
    var librarySelectionIndexFont: UIFont { get }
    var libraryItemBadgeTextColor: UIColor { get }
    var libraryItemBadgeBackgroundColor: UIColor { get }
    var libraryItemBadgeCornerRadius: CGFloat { get }
    
    var closeIcon: UIImage? { get }
    var closeIconColor: UIColor { get }
    
    var cameraIcon: UIImage? { get }
    var cameraIconColor: UIColor { get }
    var cameraCornerRadius: CGFloat { get }
    
    var progressIndicatorColor: UIColor { get }
}
