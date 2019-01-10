import Foundation
import ImageSource

final class PhotoLibraryInteractorImpl: PhotoLibraryInteractor {
    
    // MARK: - State
    private var maxSelectedItemsCount: Int?
    private var onAlbumEvent: ((PhotoLibraryAlbumEvent, PhotoLibraryItemSelectionState) -> ())?
    
    // MARK: - Dependencies
    private let photoLibraryItemsService: PhotoLibraryItemsService
    
    // MARK: - Init
    
    init(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int? = nil,
        photoLibraryItemsService: PhotoLibraryItemsService)
    {
        self.selectedItems = selectedItems
        self.maxSelectedItemsCount = maxSelectedItemsCount
        self.photoLibraryItemsService = photoLibraryItemsService
    }
    
    // MARK: - PhotoLibraryInteractor
    private(set) var currentAlbum: PhotoLibraryAlbum?
    private(set) var selectedItems = [PhotoLibraryItem]()
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        photoLibraryItemsService.observeAuthorizationStatus(handler: handler)
    }
    
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ()) {
        photoLibraryItemsService.observeAlbums { [weak self] albums in
            if let currentAlbum = self?.currentAlbum {
                // Reset current album if it has been removed, otherwise refresh it (title might have been changed).
                self?.currentAlbum = albums.first { $0 == currentAlbum }
            }
            handler(albums)
        }
    }
    
    func observeCurrentAlbumEvents(handler: @escaping (PhotoLibraryAlbumEvent, PhotoLibraryItemSelectionState) -> ()) {
        onAlbumEvent = handler
    }
    
    func isSelected(_ item: PhotoLibraryItem) -> Bool {
        return selectedItems.contains(item)
    }
    
    func selectItem(_ item: PhotoLibraryItem) -> PhotoLibraryItemSelectionState {
        if canSelectMoreItems() {
            selectedItems.append(item)
        }
        return selectionState()
    }
    
    func deselectItem(_ item: PhotoLibraryItem) -> PhotoLibraryItemSelectionState {
        if let index = selectedItems.index(of: item) {
            selectedItems.remove(at: index)
        }
        return selectionState()
    }
    
    func prepareSelection() -> PhotoLibraryItemSelectionState {
        if selectedItems.count > 0 && maxSelectedItemsCount == 1 {
            selectedItems.removeAll()
            return selectionState(preSelectionAction: .deselectAll)
        } else {
            return selectionState()
        }
    }
    
    func setCurrentAlbum(_ album: PhotoLibraryAlbum) {
        guard album != currentAlbum else { return }
        
        currentAlbum = album
        
        photoLibraryItemsService.observeEvents(in: album) { [weak self] event in
            guard let strongSelf = self else { return }
            
            // TODO: (ayutkin) find a way to remove items in `selectedItems` that refer to removed assets
            
            if let onAlbumEvent = strongSelf.onAlbumEvent {
                dispatch_to_main_queue {
                    onAlbumEvent(event, strongSelf.selectionState())
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func canSelectMoreItems() -> Bool {
        return maxSelectedItemsCount.flatMap { selectedItems.count < $0 } ?? true
    }
    
    private func selectionState(preSelectionAction: PhotoLibraryItemSelectionState.PreSelectionAction = .none) -> PhotoLibraryItemSelectionState {
        return PhotoLibraryItemSelectionState(
            isAnyItemSelected: selectedItems.count > 0,
            canSelectMoreItems: canSelectMoreItems(),
            preSelectionAction: preSelectionAction
        )
    }
}
