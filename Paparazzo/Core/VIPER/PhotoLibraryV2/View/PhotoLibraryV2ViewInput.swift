import Foundation
import ImageSource

protocol PhotoLibraryV2ViewInput: class {
    
    var onTitleTap: (() -> ())? { get set }
    var onDimViewTap: (() -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    
    func setTitle(_: String)
    func setTitleVisible(_: Bool)
    
    func setContinueButtonTitle(_: String)
    func setContinueButtonVisible(_: Bool)
    func setContinueButtonStyle(_: MediaPickerContinueButtonStyle)
    func setContinueButtonPlacement(_: MediaPickerContinueButtonPlacement)
    
    func setPlaceholderState(_: PhotoLibraryPlaceholderState)
    
    func setCameraViewData(_: PhotoLibraryCameraViewData?)
    
    func setItems(_: [PhotoLibraryItemCellData], scrollToTop: Bool, completion: (() -> ())?)
    func applyChanges(_: PhotoLibraryViewChanges, completion: (() -> ())?)
    
    func setCanSelectMoreItems(_: Bool)
    func setDimsUnselectedItems(_: Bool)
    
    func deselectItem(with: ImageSource) -> Bool
    func deselectAllItems()
    func reloadSelectedItems()
    
    func setAlbums(_: [PhotoLibraryAlbumCellData])
    func selectAlbum(withId: String)
    func showAlbumsList()
    func hideAlbumsList()
    func toggleAlbumsList()
    
    func setSelectedPhotosBarState(_: SelectedPhotosBarState)
    
    var onContinueButtonTap: (() -> ())? { get set }
    var onCloseButtonTap: (() -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    var onViewWillAppear: (() -> ())? { get set }
    
    func setProgressVisible(_ visible: Bool)
    func setHeaderVisible(_ visible: Bool)
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    func setDoneButtonTitle(_: String)
    func setPlaceholderText(_: String)
}

struct PhotoLibraryCameraViewData {
    let parameters: CameraOutputParameters?
    let onTap: (() -> ())?
}
