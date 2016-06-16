import Foundation

final class PhotoLibraryInteractorImpl: PhotoLibraryInteractor {
    
    private var selectedItems = [PhotoLibraryItem]()
    private let maxSelectedItemsCount: Int?
    
    // MARK: - Dependencies
    
    private let photoLibraryItemsService: PhotoLibraryItemsService
    
    // MARK: - Init
    
    init(maxSelectedItemsCount: Int? = nil, photoLibraryItemsService: PhotoLibraryItemsService) {
        self.maxSelectedItemsCount = maxSelectedItemsCount
        self.photoLibraryItemsService = photoLibraryItemsService
    }
    
    // MARK: - PhotoLibraryInteractor
    
    func observeItems(handler: (items: [PhotoLibraryItem], selectionState: PhotoLibraryItemSelectionState) -> ()) {
        
        photoLibraryItemsService.observePhotos { [weak self] assets in
            guard let strongSelf = self else { return }
            
            let items = assets.map { asset -> PhotoLibraryItem in
                
                let identifier = asset.localIdentifier
                let image = PhotoLibraryAssetImage(asset: asset)
                
                return PhotoLibraryItem(
                    identifier: identifier,
                    image: image,
                    selected: strongSelf.selectedItems.contains { $0.identifier == identifier }
                )
            }
            
            handler((
                items: items,
                selectionState: strongSelf.selectionState()
            ))
        }
    }
    
    func selectItem(item: PhotoLibraryItem, completion: PhotoLibraryItemSelectionState -> ()) {
        
        if canSelectMoreItems() {
            selectedItems.append(item)
        }
        
        completion(selectionState())
    }
    
    func deselectItem(item: PhotoLibraryItem, completion: PhotoLibraryItemSelectionState -> ()) {
        
        if let index = selectedItems.indexOf(item) {
            selectedItems.removeAtIndex(index)
        }
        
        completion(selectionState())
    }
    
    func selectedItems(completion: (items: [PhotoLibraryItem], canSelectMoreItems: Bool) -> ()) {
        completion(items: selectedItems, canSelectMoreItems: canSelectMoreItems())
    }
    
    // MARK: - Private
    
    private func canSelectMoreItems() -> Bool {
        return maxSelectedItemsCount.flatMap { selectedItems.count < $0 } ?? true
    }
    
    private func selectionState() -> PhotoLibraryItemSelectionState {
        return PhotoLibraryItemSelectionState(
            isAnyItemSelected: selectedItems.count > 0,
            canSelectMoreItems: canSelectMoreItems()
        )
    }
}
