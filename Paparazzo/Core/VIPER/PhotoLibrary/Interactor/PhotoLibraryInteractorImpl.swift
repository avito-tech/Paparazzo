import Foundation
import ImageSource

final class PhotoLibraryInteractorImpl: PhotoLibraryInteractor {
    
    // MARK: - Data
    private(set) var selectedItems = [PhotoLibraryItem]()
    private var maxSelectedItemsCount: Int?
    
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
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        photoLibraryItemsService.observeAuthorizationStatus(handler: handler)
    }
    
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ()) {
        photoLibraryItemsService.observeAlbums(handler: handler)
    }
    
    func observeEvents(
        in album: PhotoLibraryAlbum,
        handler: @escaping (_ event: PhotoLibraryEvent, _ selectionState: PhotoLibraryItemSelectionState) -> ())
    {
        photoLibraryItemsService.observeEvents(in: album) { [weak self] event in
            guard let strongSelf = self else { return }
            
            // TODO: (ayutkin) if event == .changes, remove `removedItems` from `selectedItems`
//            strongSelf.removeSelectedItems(notPresentedIn: strongSelf.allItems)
            
            dispatch_to_main_queue {
                handler(event, strongSelf.selectionState())
            }
        }
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
    
    private func removeSelectedItems(notPresentedIn items: [PhotoLibraryItem]) {
        let assetIds = Set(items.map { $0.identifier })
        selectedItems = selectedItems.filter { assetIds.contains($0.identifier) }
    }
}
