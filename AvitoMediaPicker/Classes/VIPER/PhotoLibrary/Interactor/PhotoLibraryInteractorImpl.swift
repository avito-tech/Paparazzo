import Foundation
import Photos

final class PhotoLibraryInteractorImpl: PhotoLibraryInteractor {
    
    private var assets = [PHAsset]()
    private var selectedItems = [PhotoLibraryItem]()
    private var maxSelectedItemsCount: Int?
    
    // MARK: - Dependencies
    
    private let photoLibraryItemsService: PhotoLibraryItemsService
    
    private var _imageManager: PHImageManager?

    // Нельзя сразу создавать PHImageManager, иначе он крэшнется при деаллокации, если доступ к photo library запрещен
    private var imageManager: PHImageManager {
        if let imageManager = _imageManager {
            return imageManager
        } else {
            let imageManager = PHImageManager()
            _imageManager = imageManager
            return imageManager
        }
    }
    
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
    
    func setMaxSelectedItemsCount(count: Int?) {
        maxSelectedItemsCount = count
    }
    
    func authorizationStatus(completion: (_ accessGranted: Bool) -> ()) {
        completion(photoLibraryItemsService.authorizationStatus == .authorized)
    }
    
    func observeItems(handler: @escaping (_ changes: PhotoLibraryChanges, _ selectionState: PhotoLibraryItemSelectionState) -> ()) {
        
        photoLibraryItemsService.observePhotos { [weak self] assets, phChanges in
            guard let strongSelf = self else { return }
            
            var assets = assets
            let changes: PhotoLibraryChanges
            
            if let phChanges = phChanges {
                
                let changesAndAssets = strongSelf.photoLibraryChanges(from: phChanges)
                
                changes = changesAndAssets.changes
                assets = changesAndAssets.assets
                
            } else {
                
                let items = strongSelf.photoLibraryItems(from: assets)
                
                var index = -1
                let insertedItems = items.map { item -> (index: Int, item: PhotoLibraryItem) in
                    index += 1
                    return (index: index, item: item)
                }
                
                changes = PhotoLibraryChanges(
                    removedIndexes: NSIndexSet(),
                    insertedItems: insertedItems,
                    updatedItems: [],
                    movedIndexes: [],
                    itemsAfterChanges: items
                )
            }
            
            strongSelf.assets = assets
            strongSelf.removeSelectedItemsNotPresentedAmongAssets(assets)
            
            dispatch_to_main_queue {
                handler(changes, strongSelf.selectionState())
            }
        }
    }
    
    func selectItem(item: PhotoLibraryItem, completion: (PhotoLibraryItemSelectionState) -> ()) {
        
        if canSelectMoreItems() {
            selectedItems.append(item)
        }
        
        completion(selectionState())
    }
    
    func deselectItem(item: PhotoLibraryItem, completion: (PhotoLibraryItemSelectionState) -> ()) {
        
        if let index = selectedItems.indexOf(item) {
            selectedItems.removeAtIndex(index)
        }
        
        completion(selectionState())
    }
    
    func selectedItems(completion: [PhotoLibraryItem] -> ()) {
        completion(selectedItems)
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
    
    private func removeSelectedItemsNotPresentedAmongAssets(_ assets: [PHAsset]) {
        let assetIds = Set(assets.map { $0.localIdentifier })
        selectedItems = selectedItems.filter { assetIds.contains($0.identifier) }
    }
    
    private func photoLibraryItems(from assets: [PHAsset]) -> [PhotoLibraryItem] {
        return assets.map(photoLibraryItem)
    }
    
    private func photoLibraryItem(from asset: PHAsset) -> PhotoLibraryItem {
        let identifier = asset.localIdentifier
        let image = PHAssetImageSource(asset: asset, imageManager: imageManager)
        
        return PhotoLibraryItem(
            identifier: identifier,
            image: image,
            selected: selectedItems.contains { $0.identifier == identifier }
        )
    }
    
    private func photoLibraryChanges(from changes: PHFetchResultChangeDetails)
        -> (changes: PhotoLibraryChanges, assets: [PHAsset])
    {
        var assets = [PHAsset?]()
        
        var insertedObjects = [(index: Int, item: PhotoLibraryItem)]()
        var insertedObjectIndex = changes.insertedObjects.count - 1
        
        var updatedObjects = [(index: Int, item: PhotoLibraryItem)]()
        var updatedObjectIndex = changes.changedObjects.count - 1
        
        var movedIndexes = [(from: Int, to: Int)]()
        
        changes.fetchResultBeforeChanges.enumerateObjectsUsingBlock { object, _, _ in
            assets.append(object as? PHAsset)
        }
        
        changes.removedIndexes?.enumerateIndexesWithOptions(.Reverse) { index, _ in
            assets.removeAtIndex(index)
        }
        
        changes.insertedIndexes?.enumerateIndexesWithOptions(.Reverse) { index, stop in
            guard insertedObjectIndex >= 0 else { stop.memory = ObjCBool(true); return }
            if let asset = changes.insertedObjects[insertedObjectIndex] as? PHAsset {
                insertedObjects.append((index: index, item: self.photoLibraryItem(from: asset)))
            }
            insertedObjectIndex -= 1
        }
        
        changes.changedIndexes?.enumerateIndexesWithOptions(.Reverse) { index, stop in
            guard updatedObjectIndex >= 0 else { stop.memory = ObjCBool(true); return }
            if let asset = changes.changedObjects[updatedObjectIndex] as? PHAsset {
                updatedObjects.append((index: index, item: self.photoLibraryItem(from: asset)))
            }
            updatedObjectIndex -= 1
        }
        
        changes.enumerateMovesWithBlock { from, to in
            movedIndexes.append((from: from, to: to))
        }
        
        let nonNilAssets = assets.flatMap {$0}
        assert(nonNilAssets.count == assets.count, "Objects other than PHAsset are not supported")
        
        let changes = PhotoLibraryChanges(
            removedIndexes: changes.removedIndexes ?? NSIndexSet(),
            insertedItems: insertedObjects,
            updatedItems: updatedObjects,
            movedIndexes: movedIndexes,
            itemsAfterChanges: photoLibraryItems(from: nonNilAssets)
        )
        
        return (changes: changes, assets: nonNilAssets)
    }
}
