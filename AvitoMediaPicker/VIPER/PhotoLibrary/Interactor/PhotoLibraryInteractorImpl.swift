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
    
    func observeItems(handler: [PhotoLibraryItem] -> ()) {
        photoLibraryItemsService.observePhotos { [weak self] assets in
            handler(assets.map { asset in
                
                let image = PhotoLibraryAssetImage(asset: asset)
                
                var item = PhotoLibraryItem(identifier: asset.localIdentifier, image: image)
                item.selected = self?.selectedItems.contains(item) ?? false
                
                return item
            })
        }
    }
    
    func selectItem(item: PhotoLibraryItem, completion: (canSelectMoreItems: Bool) -> ()) {
        
        let canSelectMoreItems = self.canSelectMoreItems()
        
        if canSelectMoreItems {
            selectedItems.append(item)
        }
        
        completion(canSelectMoreItems: canSelectMoreItems)
    }
    
    func deselectItem(item: PhotoLibraryItem, completion: (canSelectMoreItems: Bool) -> ()) {
        
        if let index = selectedItems.indexOf(item) {
            selectedItems.removeAtIndex(index)
        }
        
        completion(canSelectMoreItems: canSelectMoreItems())
    }
    
    func selectedItems(completion: (items: [PhotoLibraryItem], canSelectMoreItems: Bool) -> ()) {
        completion(items: selectedItems, canSelectMoreItems: canSelectMoreItems())
    }
    
    // MARK: - Private
    
    private func canSelectMoreItems() -> Bool {
        return maxSelectedItemsCount.flatMap { selectedItems.count < $0 } ?? true
    }
}
