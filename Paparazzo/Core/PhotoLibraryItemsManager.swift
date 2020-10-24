import Dispatch
import ImageSource
import Photos

enum ItemIndex: Equatable {
    case skipped
    case finalIndex(Int)
    
    static func ==(index1: ItemIndex, index2: ItemIndex) -> Bool {
        switch (index1, index2) {
        case (.skipped, .skipped):
            return true
        case let (.finalIndex(index1), .finalIndex(index2)):
            return index1 == index2
        default:
            return false
        }
    }
}

final class PhotoLibraryItemsManager {
    
    private let photosOrder: PhotosOrder
    private let imageManager: PHImageManager
    
    var indexMap = [Int: ItemIndex]()
    var imagesCountdown = 1000
    
    init(photosOrder: PhotosOrder = .normal, imageManager: PHImageManager) {
        self.photosOrder = photosOrder
        self.imageManager = imageManager
    }
    
    func setItems(from fetchResult: PHFetchResult<PHAsset>, onLibraryChanged: @escaping (PhotoLibraryChanges) -> ())
        -> [PhotoLibraryItem]
    {
        var skippedItemsCount = 0
        var imagesCountdown = self.imagesCountdown
        
        let totalAssetsCount = fetchResult.count
        var lastIndex: Int?
        
        var finalIndexes = IndexSet()
        
        //  TODO: if photosOrder == .reversed, we need to filter out LAST photos
        
        // filtering `imagesCountdown` first images
        fetchResult.enumerateObjects { asset, originalIndex, stop in
            guard asset.mediaType == .image else {
                self.indexMap[originalIndex] = .skipped
                skippedItemsCount += 1
                return
            }
            
            finalIndexes.insert(originalIndex)
            
            self.indexMap[originalIndex] = .finalIndex(originalIndex - skippedItemsCount)
            
            imagesCountdown -= 1
            
            if imagesCountdown == 0 {
                lastIndex = originalIndex + 1
                stop.pointee = true
            }
        }
        
        
        if let lastIndex = lastIndex, lastIndex < totalAssetsCount - 1 {
            
            // iterating indexes is much faster than enumerating assets in fetch result
            (lastIndex ..< totalAssetsCount).forEach { index in
                finalIndexes.insert(index)
                self.indexMap[index] = .finalIndex(index - skippedItemsCount)
            }
            
            // launch background removal of assets with mediaType other than .image
            DispatchQueue.global(qos: .background).async {
                let indexSet = IndexSet(integersIn: lastIndex ..< totalAssetsCount)
                var indexesToRemove = IndexSet()
                
                fetchResult.enumerateObjects(at: indexSet, options: []) { asset, originalIndex, _ in
                    if asset.mediaType != .image {
                        indexesToRemove.insert(originalIndex - skippedItemsCount)
                    }
                }
                
                onLibraryChanged(PhotoLibraryChanges(
                    removedIndexes: indexesToRemove,
                    insertedItems: [],
                    updatedItems: [],
                    movedIndexes: [],
                    itemsAfterChangesCount: totalAssetsCount - skippedItemsCount - indexesToRemove.count
                ))
            }
        }
        
        return photoLibraryItems(from: fetchResult, indexes: finalIndexes)
    }
    
    func handleChanges(
        _ changes: PHFetchResultChangeDetails<PHAsset>,
        completion: @escaping (PhotoLibraryChanges) -> ())
    {
        // TODO: calculate indexes on background thread
        
        completion(PhotoLibraryChanges(
            removedIndexes: removedIndexes(from: changes),
            insertedItems: insertedObjects(from: changes),
            updatedItems: updatedObjects(from: changes),
            movedIndexes: movedIndexes(from: changes),
            itemsAfterChangesCount: changes.fetchResultAfterChanges.count
        ))
    }
    
    // MARK: - Private
    private func removedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> IndexSet
    {
        let assetsCountBeforeChanges = changes.fetchResultBeforeChanges.count
        var removedIndexes = IndexSet()
        
        switch photosOrder {
        case .normal:
            changes.removedIndexes?.reversed().forEach { index in
                removedIndexes.insert(index)
            }
        case .reversed:
            changes.removedIndexes?.forEach { index in
                removedIndexes.insert(assetsCountBeforeChanges - index - 1)
            }
        }
        
        return removedIndexes
    }
    
    private func insertedObjects(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        guard let insertedIndexes = changes.insertedIndexes else { return [] }
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        /*
         To clarify the code below:
         
         `insertionIndex` — index used to map `changes.insertedIndexes` to `changes.insertedObjects`.
         
         `targetAssetIndex` — target index at which asset has been inserted to photo library
             as reported to us by PhotoKit.
         
         `finalAssetIndex` — actual target index at which collection view cell for the asset will be inserted.
             This is the same as `targetAssetIndex` if `photosOrder` is `.normal`.
             However if `photosOrder` is `.reversed` we need to do some calculation.
         */
        return insertedIndexes.enumerated().map {
            insertionIndex, targetAssetIndex -> (index: Int, item: PhotoLibraryItem) in
            
            let asset = changes.insertedObjects[insertionIndex]
            
            let finalAssetIndex: Int = {
                switch photosOrder {
                case .normal:
                    return targetAssetIndex
                case .reversed:
                    return objectsCountAfterRemovalsAndInsertions - targetAssetIndex - 1
                }
            }()
            
            return (index: finalAssetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    private func updatedObjects(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(index: Int, item: PhotoLibraryItem)]
    {
        guard let changedIndexes = changes.changedIndexes else { return [] }
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        /*
         To clarify the code below:
         
         `changeIndex` — index used to map `changes.changedIndexes` to `changes.changedObjects`.

         `assetIndex` — index at which asset has been updated in photo library as reported to us by PhotoKit.
         
         `finalAssetIndex` — actual index of a collection view cell for the asset that will be updated.
             This is the same as `assetIndex` if `photosOrder` is `.normal`.
             However if `photosOrder` is `.reversed` we need to do some calculation.
         */
        return changedIndexes.enumerated().map { changeIndex, assetIndex -> (index: Int, item: PhotoLibraryItem) in
            
            let asset = changes.changedObjects[changeIndex]
            
            let finalAssetIndex: Int = {
                switch photosOrder {
                case .normal:
                    return assetIndex
                case .reversed:
                    return objectsCountAfterRemovalsAndInsertions - assetIndex - 1
                }
            }()
            
            return (index: finalAssetIndex, item: photoLibraryItem(from: asset))
        }
    }
    
    private func movedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> [(from: Int, to: Int)]
    {
        var movedIndexes = [(from: Int, to: Int)]()
        
        let objectsCountAfterRemovalsAndInsertions =
            changes.fetchResultBeforeChanges.count - changes.removedObjects.count + changes.insertedObjects.count
        
        changes.enumerateMoves { from, to in
            
            let (realFrom, realTo): (Int, Int) = {
                switch self.photosOrder {
                case .normal:
                    return (from, to)
                case .reversed:
                    return (
                        objectsCountAfterRemovalsAndInsertions - from - 1,
                        objectsCountAfterRemovalsAndInsertions - to - 1
                    )
                }
            }()
            
            movedIndexes.append((from: realFrom, to: realTo))
        }
        
        return movedIndexes
    }
    
    private func photoLibraryItem(from asset: PHAsset) -> PhotoLibraryItem {
        return PhotoLibraryItem(
            image: PHAssetImageSource(asset: asset, imageManager: imageManager)
        )
    }
    
    private func photoLibraryItems(from fetchResult: PHFetchResult<PHAsset>, indexes: IndexSet) -> [PhotoLibraryItem] {
        let startTime = Date()
        defer {
            print("photoLibraryItems took \(Date().timeIntervalSince(startTime)) sec")
        }
        
        let getPhotoLibraryItem = { (index: Int) -> PhotoLibraryItem in
            PhotoLibraryItem(
                image: PHAssetImageSource(
                    fetchResult: fetchResult,
                    index: index,
                    imageManager: self.imageManager
                )
            )
        }
        
        switch photosOrder {
        case .normal:
            return (0 ..< fetchResult.count).map(getPhotoLibraryItem)
        case .reversed:
            return (0 ..< fetchResult.count).reversed().map(getPhotoLibraryItem)
        }
    }
}
