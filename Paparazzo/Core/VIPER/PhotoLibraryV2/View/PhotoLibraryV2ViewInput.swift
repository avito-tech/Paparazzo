import Foundation
import ImageSource

protocol PhotoLibraryV2ViewInput: class {
    
    var onTitleTap: (() -> ())? { get set }
    var onDimViewTap: (() -> ())? { get set }
    
    func setTitle(_: String)
    func setTitleVisible(_: Bool)
    
    func setContinueButtonTitle(_: String)
    
    func setPlaceholderState(_: PhotoLibraryPlaceholderState)
    
    func setCameraViewData(_: PhotoLibraryCameraViewData)
    
    func setItems(_: [PhotoLibraryItemCellData], scrollToBottom: Bool, completion: (() -> ())?)
    func applyChanges(_: PhotoLibraryViewChanges, completion: (() -> ())?)
    
    func setCanSelectMoreItems(_: Bool)
    func setDimsUnselectedItems(_: Bool)
    
    func deselectAllItems()
    
    func scrollToBottom()
    
    func setAlbums(_: [PhotoLibraryAlbumCellData])
    func selectAlbum(withId: String)
    func showAlbumsList()
    func hideAlbumsList()
    func toggleAlbumsList()
    
    var onContinueButtonTap: (() -> ())? { get set }
    var onCloseButtonTap: (() -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    
    func setProgressVisible(_ visible: Bool)
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
}

struct PhotoLibraryCameraViewData {
    let parameters: CameraOutputParameters
    let onTap: (() -> ())?
}
