import Foundation
import ImageSource

final class PhotoLibraryInteractorImpl: PhotoLibraryInteractor {
    
    // MARK: - Data
    private var allItems = [PhotoLibraryItem]()
    private var selectedItems = [PhotoLibraryItem]()
    private var maxSelectedItemsCount: Int?
    
    // MARK: - Dependencies
    private let photoLibraryItemsService: PhotoLibraryItemsService
    
    // MARK: - Init
    
    init(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int? = nil,
        photoLibraryItemsService: PhotoLibraryItemsService
    ) {
        self.selectedItems = selectedItems
        self.maxSelectedItemsCount = maxSelectedItemsCount
        self.photoLibraryItemsService = photoLibraryItemsService
    }
    
    // MARK: - PhotoLibraryInteractor
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        photoLibraryItemsService.observeAuthorizationStatus(handler: handler)
    }
    
    func observeItems(handler: @escaping (_ changes: PhotoLibraryChanges, _ selectionState: PhotoLibraryItemSelectionState) -> ()) {
        
        photoLibraryItemsService.observeItems { [weak self] changes in
            guard let strongSelf = self else { return }
            
            strongSelf.allItems = changes.itemsAfterChanges.map { item in
                PhotoLibraryItem(
                    identifier: item.identifier,
                    image: item.image,
                    selected: strongSelf.selectedItems.contains(item)
                )
            }
            
            strongSelf.removeSelectedItems(notPresentedIn: strongSelf.allItems)
            
            dispatch_to_main_queue {
                handler(changes, strongSelf.selectionState())
            }
        }
    }
    
    func selectItem(_ item: PhotoLibraryItem, completion: @escaping (PhotoLibraryItemSelectionState) -> ()) {
        
        if canSelectMoreItems() {
            selectedItems.append(item)
        }
        
        completion(selectionState())
    }
    
    func deselectItem(_ item: PhotoLibraryItem, completion: @escaping (PhotoLibraryItemSelectionState) -> ()) {
        
        if let index = selectedItems.index(of: item) {
            selectedItems.remove(at: index)
        }
        
        completion(selectionState())
    }
    
    func prepareSelection(completion: @escaping (PhotoLibraryItemSelectionState) -> ()) {
        if selectedItems.count > 0 && maxSelectedItemsCount == 1 {
            selectedItems.removeAll()
            completion(selectionState(preSelectionAction: .deselectAll))
        } else {
            completion(selectionState())
        }
    }
    
    func selectedItems(completion: @escaping ([PhotoLibraryItem]) -> ()) {
        completion(selectedItems)
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
