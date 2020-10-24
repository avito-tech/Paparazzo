@testable import Paparazzo
@testable import ImageSource
import Photos
import XCTest

final class PhotoLibraryItemsManagerTests: XCTestCase {
    
    func test1() {
        let onLibraryChangedNotCalled = expectation(description: "`onLibraryChanged` not called")
        onLibraryChangedNotCalled.isInverted = true
        
        let a = PhotoLibraryItemsManager(imageManager: PHImageManager.default())
        a.imagesCountdown = 10
        
        let finalItems = a.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .image),
                PHAssetMock(localIdentifier: "1", mediaType: .video),   // will be skipped immediately
                PHAssetMock(localIdentifier: "2", mediaType: .image),
                PHAssetMock(localIdentifier: "3", mediaType: .image),
                PHAssetMock(localIdentifier: "4", mediaType: .audio),   // will be skipped immediately
                PHAssetMock(localIdentifier: "5", mediaType: .video),   // will be skipped immediately
                PHAssetMock(localIdentifier: "6", mediaType: .image),
                PHAssetMock(localIdentifier: "7", mediaType: .image),
                PHAssetMock(localIdentifier: "8", mediaType: .image),
                PHAssetMock(localIdentifier: "9", mediaType: .unknown)   // will be skipped immediately
            ]),
            onLibraryChanged: { _ in
                onLibraryChangedNotCalled.fulfill()
            }
        )
        
        XCTAssertEqual(finalItems.count, 6)
        
        XCTAssertEqual(asset(from: finalItems[0]).localIdentifier, "0")
        XCTAssertEqual(asset(from: finalItems[1]).localIdentifier, "2")
        XCTAssertEqual(asset(from: finalItems[2]).localIdentifier, "3")
        XCTAssertEqual(asset(from: finalItems[3]).localIdentifier, "6")
        XCTAssertEqual(asset(from: finalItems[4]).localIdentifier, "7")
        XCTAssertEqual(asset(from: finalItems[5]).localIdentifier, "8")
        
        XCTAssertEqual(a.indexMap[0], .finalIndex(0))
        XCTAssertEqual(a.indexMap[1], .skipped)
        XCTAssertEqual(a.indexMap[2], .finalIndex(1))
        XCTAssertEqual(a.indexMap[3], .finalIndex(2))
        XCTAssertEqual(a.indexMap[4], .skipped)
        XCTAssertEqual(a.indexMap[5], .skipped)
        XCTAssertEqual(a.indexMap[6], .finalIndex(3))
        XCTAssertEqual(a.indexMap[7], .finalIndex(4))
        XCTAssertEqual(a.indexMap[8], .finalIndex(5))
        XCTAssertEqual(a.indexMap[9], .skipped)
        
        wait(for: [onLibraryChangedNotCalled], timeout: 2)
    }
    
    func test2() {
        let onLibraryChangedCalled = expectation(description: "`onLibraryChanged` called")
        var recordedChanges: PhotoLibraryChanges?
        
        let manager = PhotoLibraryItemsManager(imageManager: PHImageManager.default())
        manager.imagesCountdown = 5
        
        let finalItems = manager.setItems(
            from: PHAssetFetchResultMock(assets: [
                PHAssetMock(localIdentifier: "0", mediaType: .image),
                PHAssetMock(localIdentifier: "1", mediaType: .video),   // will be skipped immediately
                PHAssetMock(localIdentifier: "2", mediaType: .image),
                PHAssetMock(localIdentifier: "3", mediaType: .image),
                PHAssetMock(localIdentifier: "4", mediaType: .audio),   // will be skipped immediately
                PHAssetMock(localIdentifier: "5", mediaType: .video),   // will be skipped immediately
                PHAssetMock(localIdentifier: "6", mediaType: .image),
                PHAssetMock(localIdentifier: "7", mediaType: .image),
                PHAssetMock(localIdentifier: "8", mediaType: .image),
                PHAssetMock(localIdentifier: "9", mediaType: .unknown), // will be removed after background processing
                PHAssetMock(localIdentifier: "10", mediaType: .image),
                PHAssetMock(localIdentifier: "11", mediaType: .video),   // will be removed after background processing
                PHAssetMock(localIdentifier: "12", mediaType: .image),
                PHAssetMock(localIdentifier: "13", mediaType: .image),
                PHAssetMock(localIdentifier: "14", mediaType: .audio),   // will be removed after background processing
                PHAssetMock(localIdentifier: "15", mediaType: .video),   // will be removed after background processing
                PHAssetMock(localIdentifier: "16", mediaType: .image),
                PHAssetMock(localIdentifier: "17", mediaType: .image),
                PHAssetMock(localIdentifier: "18", mediaType: .image),
                PHAssetMock(localIdentifier: "19", mediaType: .unknown)  // will be removed after background processing
            ]),
            onLibraryChanged: { changes in
                recordedChanges = changes
                onLibraryChangedCalled.fulfill()
            }
        )
        
        XCTAssertEqual(finalItems.count, 17)
        
        XCTAssertEqual(asset(from: finalItems[0]).localIdentifier, "0")
        XCTAssertEqual(asset(from: finalItems[1]).localIdentifier, "2")
        XCTAssertEqual(asset(from: finalItems[2]).localIdentifier, "3")
        XCTAssertEqual(asset(from: finalItems[3]).localIdentifier, "6")
        XCTAssertEqual(asset(from: finalItems[4]).localIdentifier, "7")
        XCTAssertEqual(asset(from: finalItems[5]).localIdentifier, "8")
        XCTAssertEqual(asset(from: finalItems[6]).localIdentifier, "9")
        XCTAssertEqual(asset(from: finalItems[7]).localIdentifier, "10")
        XCTAssertEqual(asset(from: finalItems[8]).localIdentifier, "11")
        XCTAssertEqual(asset(from: finalItems[9]).localIdentifier, "12")
        XCTAssertEqual(asset(from: finalItems[10]).localIdentifier, "13")
        XCTAssertEqual(asset(from: finalItems[11]).localIdentifier, "14")
        XCTAssertEqual(asset(from: finalItems[12]).localIdentifier, "15")
        XCTAssertEqual(asset(from: finalItems[13]).localIdentifier, "16")
        XCTAssertEqual(asset(from: finalItems[14]).localIdentifier, "17")
        XCTAssertEqual(asset(from: finalItems[15]).localIdentifier, "18")
        XCTAssertEqual(asset(from: finalItems[16]).localIdentifier, "19")
        
        XCTAssertEqual(manager.indexMap[0], .finalIndex(0))
        XCTAssertEqual(manager.indexMap[1], .skipped)
        XCTAssertEqual(manager.indexMap[2], .finalIndex(1))
        XCTAssertEqual(manager.indexMap[3], .finalIndex(2))
        XCTAssertEqual(manager.indexMap[4], .skipped)
        XCTAssertEqual(manager.indexMap[5], .skipped)
        XCTAssertEqual(manager.indexMap[6], .finalIndex(3))
        XCTAssertEqual(manager.indexMap[7], .finalIndex(4))
        XCTAssertEqual(manager.indexMap[8], .finalIndex(5))
        XCTAssertEqual(manager.indexMap[9], .finalIndex(6))
        XCTAssertEqual(manager.indexMap[10], .finalIndex(7))
        XCTAssertEqual(manager.indexMap[11], .finalIndex(8))
        XCTAssertEqual(manager.indexMap[12], .finalIndex(9))
        XCTAssertEqual(manager.indexMap[13], .finalIndex(10))
        XCTAssertEqual(manager.indexMap[14], .finalIndex(11))
        XCTAssertEqual(manager.indexMap[15], .finalIndex(12))
        XCTAssertEqual(manager.indexMap[16], .finalIndex(13))
        XCTAssertEqual(manager.indexMap[17], .finalIndex(14))
        XCTAssertEqual(manager.indexMap[18], .finalIndex(15))
        XCTAssertEqual(manager.indexMap[19], .finalIndex(16))
        
        wait(for: [onLibraryChangedCalled], timeout: 1)
        
        XCTAssertEqual(recordedChanges!.removedIndexes.count, 5)
        XCTAssert(recordedChanges!.removedIndexes.contains(6), "`removedIndexes` must contain index 6")
        XCTAssert(recordedChanges!.removedIndexes.contains(8), "`removedIndexes` must contain index 8")
        XCTAssert(recordedChanges!.removedIndexes.contains(11), "`removedIndexes` must contain index 11")
        XCTAssert(recordedChanges!.removedIndexes.contains(12), "`removedIndexes` must contain index 12")
        XCTAssert(recordedChanges!.removedIndexes.contains(16), "`removedIndexes` must contain index 16")
        XCTAssertEqual(recordedChanges!.itemsAfterChangesCount, 12)
    }
    
    // MARK: - Private
    private func asset(from libraryItem: PhotoLibraryItem) -> PHAsset {
        return (libraryItem.image as! PHAssetImageSource).asset
    }
}
