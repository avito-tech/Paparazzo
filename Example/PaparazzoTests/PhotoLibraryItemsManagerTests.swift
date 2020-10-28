@testable import Paparazzo
@testable import ImageSource
import Photos
import XCTest

final class PhotoLibraryItemsManagerTests: XCTestCase {
    
    // MARK: - `setItem` tests
    
    /**
     Source: [i, v, i]
     Min consecutive recent images: 1
     --->
     Sync filtering result: [i, v, i]
     Async filtering result: remove asset at index 1
     */
    func test_setItems_imageAndVideo_afterMinConsecutiveRecentImages() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        var recordedChanges: PhotoLibraryChanges?
        
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 1
        manager.queue.suspend()
        
        let finalItems = manager.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .image),
                PHAssetMock(localIdentifier: "1", mediaType: .video),   // will be filtered out in background
                PHAssetMock(localIdentifier: "2", mediaType: .image)
            ]),
            onLibraryChanged: { changes in
                recordedChanges = changes
                onLibraryChangedCalled.fulfill()
            }
        )
        
        XCTAssertEqual(finalItems.count, 3)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "0")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "1")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "2")
        
        XCTAssertEqual(manager.indexMap.count, 3)
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[2], .finalIndex(2))
        
        manager.queue.resume()
        wait(for: [onLibraryChangedCalled], timeout: 1)
        
        XCTAssertEqual(recordedChanges!.removedIndexes.count, 1)
        XCTAssert(recordedChanges!.removedIndexes.contains(1))
        XCTAssertEqual(recordedChanges!.itemsAfterChangesCount, 2)
        
        XCTAssertEqual(manager.indexMap.count, 3)
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .finalIndex(1))
    }
    
    /**
     Source: [i, i, v, i]
     Min consecutive recent images: 2
     --->
     Sync filtering result: [i, i, i]
     Async filtering result: -
     */
    func test_setItems_image_afterMinConsecutiveRecentImages() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        onLibraryChangedCalled.isInverted = true
        
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 2
        
        let finalItems = manager.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .image),
                PHAssetMock(localIdentifier: "1", mediaType: .image),
                PHAssetMock(localIdentifier: "2", mediaType: .video),   // will be filtered out immediately
                PHAssetMock(localIdentifier: "3", mediaType: .image)
            ]),
            onLibraryChanged: { _ in onLibraryChangedCalled.fulfill() }
        )
        
        XCTAssertEqual(finalItems.count, 3)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "0")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "1")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "3")
        
        XCTAssertEqual(manager.indexMap.count, 4)
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[2], .skipped)
        XCTAssertEqual(manager.indexMap[3], .finalIndex(2))
        
        wait(for: [onLibraryChangedCalled], timeout: 1)
    }
    
    /**
     Source: [v, i, v, i]
     Min consecutive recent images: 2
     --->
     Sync filtering result: [v, i, i]
     Async filtering result: remove asset at index 0
     */
    func test_setItems_video_afterMinConsecutiveRecentImages() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        var recordedChanges: PhotoLibraryChanges?
        
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 2
        manager.queue.suspend()
        
        let finalItems = manager.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .video),   // will be filtered out in background
                PHAssetMock(localIdentifier: "1", mediaType: .image),
                PHAssetMock(localIdentifier: "2", mediaType: .video),   // will be filtered out immediately
                PHAssetMock(localIdentifier: "3", mediaType: .image)
            ]),
            onLibraryChanged: { changes in
                recordedChanges = changes
                onLibraryChangedCalled.fulfill()
            }
        )
        
        XCTAssertEqual(finalItems.count, 3)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "0")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "1")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "3")
        
        XCTAssertEqual(manager.indexMap.count, 4)
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[2], .skipped)
        XCTAssertEqual(manager.indexMap[3], .finalIndex(2))
        
        manager.queue.resume()
        wait(for: [onLibraryChangedCalled], timeout: 1)
        
        XCTAssertEqual(recordedChanges!.removedIndexes.count, 1)
        XCTAssert(recordedChanges!.removedIndexes.contains(0))
        XCTAssertEqual(recordedChanges!.itemsAfterChangesCount, 2)
        
        XCTAssertEqual(manager.indexMap.count, 4)
        XCTAssertEqual(manager.indexMap[0], .skipped)
        XCTAssertEqual(manager.indexMap[1], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[2], .skipped)
        XCTAssertEqual(manager.indexMap[3], .finalIndex(1))
    }
    
    /**
     Source: [i, i, i, i]
     Min consecutive recent images: 2
     --->
     Sync filtering result: [i, i, i, i]
     Async filtering result: -
     */
    func test_setItems_allImages() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        onLibraryChangedCalled.isInverted = true
        
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 2
        
        let finalItems = manager.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .image),
                PHAssetMock(localIdentifier: "1", mediaType: .image),
                PHAssetMock(localIdentifier: "2", mediaType: .image),
                PHAssetMock(localIdentifier: "3", mediaType: .image)
            ]),
            onLibraryChanged: { _ in onLibraryChangedCalled.fulfill() }
        )
        
        XCTAssertEqual(finalItems.count, 4)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "0")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "1")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "2")
        XCTAssertEqual(finalItems[3].assetLocalIdentifier, "3")
        
        XCTAssertEqual(manager.indexMap.count, 4)
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[2], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(3))
        
        wait(for: [onLibraryChangedCalled], timeout: 1)
    }
    
    /**
     Source: [v, v, v, v]
     Min consecutive recent images: 2
     --->
     Sync filtering result: []
     Async filtering result: -
     */
    func test_setItems_allVideos() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        onLibraryChangedCalled.isInverted = true
        
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 2
        
        let finalItems = manager.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .video),
                PHAssetMock(localIdentifier: "1", mediaType: .video),
                PHAssetMock(localIdentifier: "2", mediaType: .video),
                PHAssetMock(localIdentifier: "3", mediaType: .video)
            ]),
            onLibraryChanged: { _ in onLibraryChangedCalled.fulfill() }
        )
        
        XCTAssertEqual(finalItems.count, 0)
        
        wait(for: [onLibraryChangedCalled], timeout: 1)
        
        XCTAssertEqual(manager.indexMap.count, 4)
        XCTAssertEqual(manager.indexMap[0], .skipped)
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .skipped)
        XCTAssertEqual(manager.indexMap[3], .skipped)
    }
    
    // MARK: - `handleChanges` tests
    
//    func test_handleChanges_allImages_normalPhotosOrder() {
//        let changesHasBeenHandled = expectation(description: "`handleChanges` completion has been called")
//        
//        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
//        manager.minConsecutiveRecentImagesCount = 3
//        
//        let assetsBeforeChange = [
//            PHAssetMock(localIdentifier: "0", mediaType: .image),   // 0
//            PHAssetMock(localIdentifier: "1", mediaType: .video),
//            PHAssetMock(localIdentifier: "2", mediaType: .image),   // 1
//            PHAssetMock(localIdentifier: "3", mediaType: .image),   // 2
//            PHAssetMock(localIdentifier: "4", mediaType: .audio),
//            PHAssetMock(localIdentifier: "5", mediaType: .image),   // 3
//            PHAssetMock(localIdentifier: "6", mediaType: .video),
//            PHAssetMock(localIdentifier: "7", mediaType: .image),   // 4
//            PHAssetMock(localIdentifier: "8", mediaType: .image),   // 5
//            PHAssetMock(localIdentifier: "9", mediaType: .unknown)
//        ]
//        
//        let removedLocalIds = ["1", "4", "6"]
//        let assetsAfterChange = assetsBeforeChange.filter { !removedLocalIds.contains($0.localIdentifier) }
//        
//        let fetchResultBeforeChange = PHAssetFetchResultMock(assets: assetsBeforeChange)
//        
//        _ = manager.setItems(from: fetchResultBeforeChange, onLibraryChanged: { _ in })
//        
//        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: true)
//        changes.setFetchResultBeforeChanges(fetchResultBeforeChange)
//        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: assetsAfterChange))
//        changes.setRemovedIndexes([1, 4, 6])
//        changes.setRemovedObjects([assetsBeforeChange[1], assetsBeforeChange[4], assetsBeforeChange[6]])
//        changes.setInsertedIndexes(nil)
//        changes.setInsertedObjects([])
//        changes.setChangedIndexes(nil)
//        changes.setChangedObjects([])
//        changes.setMoves([])
//        
//        manager.handleChanges(changes) { finalChanges in
//            XCTAssert(finalChanges.removedIndexes.isEmpty)
//            XCTAssert(finalChanges.insertedItems.isEmpty)
//            XCTAssert(finalChanges.updatedItems.isEmpty)
//            XCTAssert(finalChanges.movedIndexes.isEmpty)
//            
//            changesHasBeenHandled.fulfill()
//        }
//        
//        wait(for: [changesHasBeenHandled], timeout: 1)
//    }
    
    // MARK: - Bad tests
    func test_setItems_returnsCorrectItems_withNormalPhotosOrder() {
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = assetFetchResult.count
        
        let finalItems = manager.setItems(from: assetFetchResult, onLibraryChanged: { _ in })
        
        XCTAssertEqual(finalItems.count, 12)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "0")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "2")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "3")
        XCTAssertEqual(finalItems[3].assetLocalIdentifier, "6")
        XCTAssertEqual(finalItems[4].assetLocalIdentifier, "7")
        XCTAssertEqual(finalItems[5].assetLocalIdentifier, "8")
        XCTAssertEqual(finalItems[6].assetLocalIdentifier, "10")
        XCTAssertEqual(finalItems[7].assetLocalIdentifier, "12")
        XCTAssertEqual(finalItems[8].assetLocalIdentifier, "13")
        XCTAssertEqual(finalItems[9].assetLocalIdentifier, "16")
        XCTAssertEqual(finalItems[10].assetLocalIdentifier, "17")
        XCTAssertEqual(finalItems[11].assetLocalIdentifier, "18")
    }
    
    func test_setItems_buildsIndexMapCorrectly_withNormalPhotosOrder() {
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = assetFetchResult.count
        
        _ = manager.setItems(from: assetFetchResult, onLibraryChanged: { _ in })
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[4], .skipped)
        XCTAssertEqual(manager.indexMap[5], .skipped)
        XCTAssertEqual(manager.indexMap[6], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[9], .skipped)
        XCTAssertEqual(manager.indexMap[10], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[11], .skipped)
        XCTAssertEqual(manager.indexMap[12], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[14], .skipped)
        XCTAssertEqual(manager.indexMap[15], .skipped)
        XCTAssertEqual(manager.indexMap[16], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[19], .skipped)
    }
    
    func test_setItems_returnsCorrectItems_withReversedPhotosOrder() {
        let manager = PhotoLibraryItemsManager(photosOrder: .reversed, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = assetFetchResult.count
        
        let finalItems = manager.setItems(from: assetFetchResult, onLibraryChanged: { _ in })
        
        XCTAssertEqual(finalItems.count, 12)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "18")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "17")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "16")
        XCTAssertEqual(finalItems[3].assetLocalIdentifier, "13")
        XCTAssertEqual(finalItems[4].assetLocalIdentifier, "12")
        XCTAssertEqual(finalItems[5].assetLocalIdentifier, "10")
        XCTAssertEqual(finalItems[6].assetLocalIdentifier, "8")
        XCTAssertEqual(finalItems[7].assetLocalIdentifier, "7")
        XCTAssertEqual(finalItems[8].assetLocalIdentifier, "6")
        XCTAssertEqual(finalItems[9].assetLocalIdentifier, "3")
        XCTAssertEqual(finalItems[10].assetLocalIdentifier, "2")
        XCTAssertEqual(finalItems[11].assetLocalIdentifier, "0")
    }
    
    func test_setItems_buildsIndexMapCorrectly_withReversedPhotosOrder() {
        let manager = PhotoLibraryItemsManager(photosOrder: .reversed, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = assetFetchResult.count
        
        _ = manager.setItems(from: assetFetchResult, onLibraryChanged: { _ in })
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[4], .skipped)
        XCTAssertEqual(manager.indexMap[5], .skipped)
        XCTAssertEqual(manager.indexMap[6], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[9], .skipped)
        XCTAssertEqual(manager.indexMap[10], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[11], .skipped)
        XCTAssertEqual(manager.indexMap[12], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[14], .skipped)
        XCTAssertEqual(manager.indexMap[15], .skipped)
        XCTAssertEqual(manager.indexMap[16], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[19], .skipped)
    }
    
    
    
    // TODO: naming
    func test2() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        var recordedChanges: PhotoLibraryChanges?
        
        let manager = PhotoLibraryItemsManager(photosOrder: .normal, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 5
        manager.queue.suspend()
        
        let finalItems = manager.setItems(
            from: assetFetchResult,
            onLibraryChanged: { changes in
                recordedChanges = changes
                onLibraryChangedCalled.fulfill()
            }
        )
        
        XCTAssertEqual(finalItems.count, 17)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "0")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "1")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "2")
        XCTAssertEqual(finalItems[3].assetLocalIdentifier, "3")
        XCTAssertEqual(finalItems[4].assetLocalIdentifier, "4")
        XCTAssertEqual(finalItems[5].assetLocalIdentifier, "5")
        XCTAssertEqual(finalItems[6].assetLocalIdentifier, "6")
        XCTAssertEqual(finalItems[7].assetLocalIdentifier, "7")
        XCTAssertEqual(finalItems[8].assetLocalIdentifier, "8")
        XCTAssertEqual(finalItems[9].assetLocalIdentifier, "9")
        XCTAssertEqual(finalItems[10].assetLocalIdentifier, "10")
        XCTAssertEqual(finalItems[11].assetLocalIdentifier, "11")
        XCTAssertEqual(finalItems[12].assetLocalIdentifier, "12")
        XCTAssertEqual(finalItems[13].assetLocalIdentifier, "13")
        XCTAssertEqual(finalItems[14].assetLocalIdentifier, "16")
        XCTAssertEqual(finalItems[15].assetLocalIdentifier, "17")
        XCTAssertEqual(finalItems[16].assetLocalIdentifier, "18")
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[2], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[4], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[5], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[6], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[9], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[10], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[11], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[12], .finalIndex(12))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(13))
        XCTAssertEqual(manager.indexMap[14], .skipped)
        XCTAssertEqual(manager.indexMap[15], .skipped)
        XCTAssertEqual(manager.indexMap[16], .finalIndex(14))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(15))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(16))
        XCTAssertEqual(manager.indexMap[19], .skipped)
        
        manager.queue.resume()
        wait(for: [onLibraryChangedCalled], timeout: 1)
        
        XCTAssertEqual(recordedChanges!.removedIndexes.count, 5)
        XCTAssert(recordedChanges!.removedIndexes.contains(1), "`removedIndexes` must contain index 1")
        XCTAssert(recordedChanges!.removedIndexes.contains(4), "`removedIndexes` must contain index 4")
        XCTAssert(recordedChanges!.removedIndexes.contains(5), "`removedIndexes` must contain index 5")
        XCTAssert(recordedChanges!.removedIndexes.contains(9), "`removedIndexes` must contain index 9")
        XCTAssert(recordedChanges!.removedIndexes.contains(11), "`removedIndexes` must contain index 11")
        XCTAssertEqual(recordedChanges!.itemsAfterChangesCount, 12)
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[4], .skipped)
        XCTAssertEqual(manager.indexMap[5], .skipped)
        XCTAssertEqual(manager.indexMap[6], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[9], .skipped)
        XCTAssertEqual(manager.indexMap[10], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[11], .skipped)
        XCTAssertEqual(manager.indexMap[12], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[14], .skipped)
        XCTAssertEqual(manager.indexMap[15], .skipped)
        XCTAssertEqual(manager.indexMap[16], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[19], .skipped)
    }
    
    // TODO: naming
    func test2_reversed() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        var recordedChanges: PhotoLibraryChanges?
        
        let manager = PhotoLibraryItemsManager(photosOrder: .reversed, imageManager: PHImageManager.default())
        manager.minConsecutiveRecentImagesCount = 5
        manager.queue.suspend()
        
        let finalItems = manager.setItems(
            from: assetFetchResult,
            onLibraryChanged: { changes in
                recordedChanges = changes
                onLibraryChangedCalled.fulfill()
            }
        )
        
        XCTAssertEqual(finalItems.count, 17)
        
        XCTAssertEqual(finalItems[0].assetLocalIdentifier, "18")
        XCTAssertEqual(finalItems[1].assetLocalIdentifier, "17")
        XCTAssertEqual(finalItems[2].assetLocalIdentifier, "16")
        XCTAssertEqual(finalItems[3].assetLocalIdentifier, "13")
        XCTAssertEqual(finalItems[4].assetLocalIdentifier, "12")
        XCTAssertEqual(finalItems[5].assetLocalIdentifier, "11")
        XCTAssertEqual(finalItems[6].assetLocalIdentifier, "10")
        XCTAssertEqual(finalItems[7].assetLocalIdentifier, "9")
        XCTAssertEqual(finalItems[8].assetLocalIdentifier, "8")
        XCTAssertEqual(finalItems[9].assetLocalIdentifier, "7")
        XCTAssertEqual(finalItems[10].assetLocalIdentifier, "6")
        XCTAssertEqual(finalItems[11].assetLocalIdentifier, "5")
        XCTAssertEqual(finalItems[12].assetLocalIdentifier, "4")
        XCTAssertEqual(finalItems[13].assetLocalIdentifier, "3")
        XCTAssertEqual(finalItems[14].assetLocalIdentifier, "2")
        XCTAssertEqual(finalItems[15].assetLocalIdentifier, "1")
        XCTAssertEqual(finalItems[16].assetLocalIdentifier, "0")
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(16))
        XCTAssertEqual(manager.indexMap[1], .finalIndex(15))
        XCTAssertEqual(manager.indexMap[2], .finalIndex(14))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(13))
        XCTAssertEqual(manager.indexMap[4], .finalIndex(12))
        XCTAssertEqual(manager.indexMap[5], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[6], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[9], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[10], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[11], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[12], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[14], .skipped)
        XCTAssertEqual(manager.indexMap[15], .skipped)
        XCTAssertEqual(manager.indexMap[16], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[19], .skipped)
        
        manager.queue.resume()
        wait(for: [onLibraryChangedCalled], timeout: 1)
        
        XCTAssertEqual(recordedChanges!.removedIndexes.count, 5)
        XCTAssert(recordedChanges!.removedIndexes.contains(5), "`removedIndexes` must contain index 5")
        XCTAssert(recordedChanges!.removedIndexes.contains(7), "`removedIndexes` must contain index 7")
        XCTAssert(recordedChanges!.removedIndexes.contains(11), "`removedIndexes` must contain index 11")
        XCTAssert(recordedChanges!.removedIndexes.contains(12), "`removedIndexes` must contain index 12")
        XCTAssert(recordedChanges!.removedIndexes.contains(15), "`removedIndexes` must contain index 15")
        XCTAssertEqual(recordedChanges!.itemsAfterChangesCount, 12)
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[4], .skipped)
        XCTAssertEqual(manager.indexMap[5], .skipped)
        XCTAssertEqual(manager.indexMap[6], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[9], .skipped)
        XCTAssertEqual(manager.indexMap[10], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[11], .skipped)
        XCTAssertEqual(manager.indexMap[12], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[14], .skipped)
        XCTAssertEqual(manager.indexMap[15], .skipped)
        XCTAssertEqual(manager.indexMap[16], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[19], .skipped)
    }
    
    // MARK: - Private
    private let assetFetchResult = PHAssetFetchResultMock(assets: [
        PHAssetMock(localIdentifier: "0", mediaType: .image),
        PHAssetMock(localIdentifier: "1", mediaType: .video),   // will be removed after background processing
        PHAssetMock(localIdentifier: "2", mediaType: .image),
        PHAssetMock(localIdentifier: "3", mediaType: .image),
        PHAssetMock(localIdentifier: "4", mediaType: .audio),   // will be removed after background processing
        PHAssetMock(localIdentifier: "5", mediaType: .video),   // will be removed after background processing
        PHAssetMock(localIdentifier: "6", mediaType: .image),
        PHAssetMock(localIdentifier: "7", mediaType: .image),
        PHAssetMock(localIdentifier: "8", mediaType: .image),
        PHAssetMock(localIdentifier: "9", mediaType: .unknown), // will be removed after background processing
        PHAssetMock(localIdentifier: "10", mediaType: .image),
        PHAssetMock(localIdentifier: "11", mediaType: .video),  // will be removed after background processing
        PHAssetMock(localIdentifier: "12", mediaType: .image),
        PHAssetMock(localIdentifier: "13", mediaType: .image),
        PHAssetMock(localIdentifier: "14", mediaType: .audio),   // will be skipped immediately
        PHAssetMock(localIdentifier: "15", mediaType: .video),   // will be skipped immediately
        PHAssetMock(localIdentifier: "16", mediaType: .image),
        PHAssetMock(localIdentifier: "17", mediaType: .image),
        PHAssetMock(localIdentifier: "18", mediaType: .image),
        PHAssetMock(localIdentifier: "19", mediaType: .unknown)  // will be skipped immediately
    ])
}
