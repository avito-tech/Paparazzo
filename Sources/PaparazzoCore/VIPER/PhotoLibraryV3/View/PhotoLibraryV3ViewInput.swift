import Foundation
import ImageSource

protocol PhotoLibraryV3ViewInput: AnyObject {
    
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
    
    func setCameraViewData(_: PhotoLibraryV3CameraViewData?)
    
    func setItems(_: [PhotoLibraryV3ItemCellData], scrollToTop: Bool, completion: (() -> ())?)
    func applyChanges(_: PhotoLibraryV3ViewChanges, completion: @escaping () -> ())
    
    func setCanSelectMoreItems(_: Bool)
    func setDimsUnselectedItems(_: Bool)
    
    @discardableResult
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
    var onViewDidAppear: (() -> ())? { get set }
    var onViewDidDisappear: ((_ animated: Bool) -> ())? { get set }
    
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

struct PhotoLibraryV3CameraViewData {
    let parameters: CameraOutputParameters?
    let onTap: (() -> ())?
}

struct PhotoLibraryV3ItemCellData: Equatable {
    
    var image: ImageSource
    var selected = false
    var previewAvailable = false
    
    var onSelect: (() -> ())?
    var onSelectionPrepare: (() -> ())?
    var onDeselect: (() -> ())?
    var getSelectionIndex: (() -> Int?)?
    
    init(image: ImageSource, getSelectionIndex: (() -> Int?)? = nil) {
        self.image = image
        self.getSelectionIndex = getSelectionIndex
    }
    
    static func ==(cellData1: Self, cellData2: Self) -> Bool {
        return cellData1.image == cellData2.image
    }
}

struct PhotoLibraryV3ViewChanges {
    // Изменения применять в таком порядке: удаление, вставка, обновление, перемещение
    let removedIndexes: IndexSet
    let insertedItems: [(index: Int, cellData: PhotoLibraryV3ItemCellData)]
    let updatedItems: [(index: Int, cellData: PhotoLibraryV3ItemCellData)]
    let movedIndexes: [(from: Int, to: Int)]
}
