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
    private let allowedMediaTypes: Set<PHAssetMediaType>
    
    let queue = DispatchQueue(label: "ru.avito.AvitoMediaPicker.PhotoLibraryItemsManager.queue", qos: .userInitiated)
    private(set) var indexMap = [ItemIndex]()
    
    /**
     The guaranteed number of **consecutive** most recent image assets returned synchronously from `setItems` method
     if number of images in fetch result in more than that.
     
     See `setItems` for more info about the algorithm.
     */
    var minConsecutiveRecentImagesCount = 1000
    
    init(
        photosOrder: PhotosOrder = .normal,
        allowedMediaTypes: Set<PHAssetMediaType> = [.image, .video],
        imageManager: PHImageManager)
    {
        self.photosOrder = photosOrder
        self.allowedMediaTypes = allowedMediaTypes
        self.imageManager = imageManager
    }
    
    /**
     `setItems` method enumerates assets in fetch result filtering out non-image assets synchronously
     until the number of consecutive most recent image assets corresponds to `minConsecutiveRecentImagesCount`.
     It leaves less recent assets unfiltered.
     
     So, it returns an array where the most recent assets are **only images** and the less recent ones may as well be
     videos, audios etc.
     
     It then dispatches the removal of non-image assets on background queue, and the result of this removal
     is presented in a form of incremental change via `onLibraryChanged` closure.
     */
    func setItems(from fetchResult: PHFetchResult<PHAsset>, onLibraryChanged: @escaping (PhotoLibraryChanges) -> ())
        -> [PhotoLibraryItem]
    {
        var skippedItemsCount = 0
        var imagesCountdown = self.minConsecutiveRecentImagesCount
        
        let totalAssetsCount = fetchResult.count
        var lastIndex: Int?
        
        var finalIndexes = IndexSet()
        
        indexMap = (0 ..< fetchResult.count).map { .finalIndex($0) }
        
        // filtering `imagesCountdown` last images
        fetchResult.enumerateObjects(options: [.reverse]) { asset, originalIndex, stop in
            guard self.allowedMediaTypes.contains(asset.mediaType) else {
                self.indexMap[originalIndex] = .skipped
                skippedItemsCount += 1
                return
            }
            
            finalIndexes.insert(originalIndex)
            
            imagesCountdown -= 1
            
            if imagesCountdown == 0 {
                lastIndex = originalIndex - 1
                stop.pointee = true
            }
        }
        
        
        if let lastIndex = lastIndex, lastIndex >= 0 {
            // iterating indexes is much faster than enumerating assets in fetch result
            finalIndexes.insert(integersIn: 0...lastIndex)
        }
        
        let initialItems = photoLibraryItems(from: fetchResult, indexes: finalIndexes)
        
        if let lastIndex = lastIndex, lastIndex >= 0 {
            // launch background removal of assets with mediaType other than one of `allowedMediaTypes`
            queue.async { [photosOrder] in
                let indexSet = IndexSet(integersIn: 0...lastIndex)
                var indexesToRemove = IndexSet()
                
                fetchResult.enumerateObjects(at: indexSet, options: []) { asset, originalIndex, _ in
                    if !self.allowedMediaTypes.contains(asset.mediaType) {
                        switch photosOrder {
                        case .normal:
                            indexesToRemove.insert(originalIndex)
                        case .reversed:
                            indexesToRemove.insert(totalAssetsCount - originalIndex - 1 - skippedItemsCount)
                        }
                    }
                }
                
                guard !indexesToRemove.isEmpty else { return }
                
                // TODO: rename
                var numberOfItemsSkippedDuringBackgroundPass = 0
                
                let updateIndexMap = { (indexInFetchResult: Int, finalIndex: ItemIndex) in
                    if case let .finalIndex(finalIndex) = finalIndex {
                        if indexesToRemove.contains(finalIndex) {
                            self.indexMap[indexInFetchResult] = .skipped
                            numberOfItemsSkippedDuringBackgroundPass += 1
                        } else {
                            self.indexMap[indexInFetchResult] =
                                .finalIndex(finalIndex - numberOfItemsSkippedDuringBackgroundPass)
                        }
                    }
                }
                
                switch photosOrder {
                case .normal:
                    self.indexMap.enumerated().forEach(updateIndexMap)
                case .reversed:
                    self.indexMap.enumerated().reversed().forEach(updateIndexMap)
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
        
        return initialItems
    }
    
    func handleChanges(
        _ changes: PHFetchResultChangeDetails<PHAsset>,
        completion: @escaping (PhotoLibraryChanges) -> ())
    {
        queue.async {
            let removedIndexes = self.removedIndexes(from: changes)
            let insertedIndexes = self.insertedObjects(from: changes)
            
            var lastFinalIndex = 0
            
            let updateIndexMap = { (indexInFetchResult: Int, finalIndex: ItemIndex) in
                switch finalIndex {
                case .finalIndex:
                    self.indexMap[indexInFetchResult] = .finalIndex(lastFinalIndex)
                    lastFinalIndex += 1
                case .skipped:
                    break
                }
            }
            
            switch self.photosOrder {
            case .normal:
                self.indexMap.enumerated().forEach(updateIndexMap)
            case .reversed:
                self.indexMap.enumerated().reversed().forEach(updateIndexMap)
            }
            
            completion(PhotoLibraryChanges(
                removedIndexes: removedIndexes,
                insertedItems: insertedIndexes,
                updatedItems: self.updatedObjects(from: changes),
                movedIndexes: self.movedIndexes(from: changes),
                itemsAfterChangesCount: lastFinalIndex
            ))
            
            // TODO: itemsAfterChangesCount needs to be counted
            
            // TODO: call on main thread?
        }
    }
    
    // MARK: - Private
    private func removedIndexes(from changes: PHFetchResultChangeDetails<PHAsset>)
        -> IndexSet
    {
        var removedIndexes = IndexSet()
        
        changes.removedIndexes?.reversed().forEach { phIndex in
            switch indexMap[phIndex] {
            case  .finalIndex(let finalIndex):
                removedIndexes.insert(finalIndex)
            case .skipped:
                break
            }
            
            indexMap.remove(at: phIndex)
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
            return indexes.enumerated().map { finalIndex, originalIndex in
                indexMap[originalIndex] = .finalIndex(finalIndex)
                return getPhotoLibraryItem(originalIndex)
            }
        case .reversed:
            return indexes.reversed().enumerated().map { finalIndex, originalIndex in
                indexMap[originalIndex] = .finalIndex(finalIndex)
                return getPhotoLibraryItem(originalIndex)
            }
        }
    }
}
