import ImageSource
@testable import Paparazzo
import Photos
import XCTest

final class PhotoLibraryChangesBuilderTests: XCTestCase {
    
    // TODO: PhotoLibraryChangesBuilder
    // Static to prevent crashing on PhotoLibraryItemsServiceImpl.imageManager deallocation
    // due to disabled access to photos in unit tests
    // THIS IS A TEMPORARY WORKAROUND!
    private static let builder = PhotoLibraryItemsServiceImpl(photosOrder: .normal)
    private static let reversedBuilder = PhotoLibraryItemsServiceImpl(photosOrder: .reversed)
    
    func test_insertionToTheBeginning_withNormalOrder() {
        
        let preservedAsset1 = PHAssetMock()
        let preservedAsset2 = PHAssetMock()
        let insertedAsset1 = PHAssetMock()
        let insertedAsset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [
            preservedAsset1,
            preservedAsset2
        ]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [
            insertedAsset1,
            insertedAsset2,
            preservedAsset1,
            preservedAsset2
        ]))
        changes.setInsertedIndexes([0, 1])
        changes.setInsertedObjects([insertedAsset1, insertedAsset2])
        
        let result = type(of: self).builder.photoLibraryChanges(from: changes)
        let insertedItems = result.insertedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, result.insertedItems.count)
        
        XCTAssertEqual(0, insertedItems[0].index)
        XCTAssertEqual(insertedAsset1.localIdentifier, insertedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(1, insertedItems[1].index)
        XCTAssertEqual(insertedAsset2.localIdentifier, insertedItems[1].item.assetLocalIdentifier)
    }
    
    func test_insertionToTheEnd_withNormalOrder() {
        
        let preservedAsset1 = PHAssetMock()
        let preservedAsset2 = PHAssetMock()
        let insertedAsset1 = PHAssetMock()
        let insertedAsset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [
            preservedAsset1,
            preservedAsset2
        ]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [
            preservedAsset1,
            preservedAsset2,
            insertedAsset1,
            insertedAsset2
        ]))
        changes.setInsertedIndexes([2, 3])
        changes.setInsertedObjects([insertedAsset1, insertedAsset2])
        
        let result = type(of: self).builder.photoLibraryChanges(from: changes)
        let insertedItems = result.insertedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, result.insertedItems.count)
        
        XCTAssertEqual(2, insertedItems[0].index)
        XCTAssertEqual(insertedAsset1.localIdentifier, insertedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(3, insertedItems[1].index)
        XCTAssertEqual(insertedAsset2.localIdentifier, insertedItems[1].item.assetLocalIdentifier)
    }
    
    func test_insertionToTheBeginning_withReversedOrder() {
        
        let preservedAsset1 = PHAssetMock()
        let preservedAsset2 = PHAssetMock()
        let insertedAsset1 = PHAssetMock()
        let insertedAsset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [
            preservedAsset1,
            preservedAsset2
        ]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [
            insertedAsset1,
            insertedAsset2,
            preservedAsset1,
            preservedAsset2
        ]))
        changes.setInsertedIndexes([0, 1])
        changes.setInsertedObjects([insertedAsset1, insertedAsset2])
        
        let result = type(of: self).reversedBuilder.photoLibraryChanges(from: changes)
        let insertedItems = result.insertedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, result.insertedItems.count)
        
        XCTAssertEqual(2, insertedItems[0].index)
        XCTAssertEqual(insertedAsset2.localIdentifier, insertedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(3, insertedItems[1].index)
        XCTAssertEqual(insertedAsset1.localIdentifier, insertedItems[1].item.assetLocalIdentifier)
    }
    
    func test_insertionToTheEnd_withReversedOrder() {
        
        let preservedAsset1 = PHAssetMock()
        let preservedAsset2 = PHAssetMock()
        let insertedAsset1 = PHAssetMock()
        let insertedAsset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [
            preservedAsset1,
            preservedAsset2
        ]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [
            preservedAsset1,
            preservedAsset2,
            insertedAsset1,
            insertedAsset2
        ]))
        changes.setInsertedIndexes([2, 3])
        changes.setInsertedObjects([insertedAsset1, insertedAsset2])
        
        let result = type(of: self).reversedBuilder.photoLibraryChanges(from: changes)
        let insertedItems = result.insertedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, result.insertedItems.count)
        
        XCTAssertEqual(0, insertedItems[0].index)
        XCTAssertEqual(insertedAsset2.localIdentifier, insertedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(1, insertedItems[1].index)
        XCTAssertEqual(insertedAsset1.localIdentifier, insertedItems[1].item.assetLocalIdentifier)
    }
    
    func test_updateAtTheBeginning_withNormalOrder() {
        
        let asset0 = PHAssetMock()
        let asset1 = PHAssetMock()
        let asset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setChangedIndexes([0, 1])
        changes.setChangedObjects([asset0, asset1])
        
        let result = type(of: self).builder.photoLibraryChanges(from: changes)
        let updatedItems = result.updatedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, updatedItems.count)
        
        XCTAssertEqual(0, updatedItems[0].index)
        XCTAssertEqual(asset0.localIdentifier, updatedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(1, updatedItems[1].index)
        XCTAssertEqual(asset1.localIdentifier, updatedItems[1].item.assetLocalIdentifier)
    }
    
    func test_updateAtTheBeginning_withReversedOrder() {
        
        let asset0 = PHAssetMock()
        let asset1 = PHAssetMock()
        let asset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setChangedIndexes([0, 1])
        changes.setChangedObjects([asset0, asset1])
        
        let result = type(of: self).reversedBuilder.photoLibraryChanges(from: changes)
        let updatedItems = result.updatedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, updatedItems.count)
        
        XCTAssertEqual(1, updatedItems[0].index)
        XCTAssertEqual(asset1.localIdentifier, updatedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(2, updatedItems[1].index)
        XCTAssertEqual(asset0.localIdentifier, updatedItems[1].item.assetLocalIdentifier)
    }
    
    func test_updateAtTheEnd_withNormalOrder() {
        
        let asset0 = PHAssetMock()
        let asset1 = PHAssetMock()
        let asset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setChangedIndexes([1, 2])
        changes.setChangedObjects([asset1, asset2])
        
        let result = type(of: self).builder.photoLibraryChanges(from: changes)
        let updatedItems = result.updatedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, updatedItems.count)
        
        XCTAssertEqual(1, updatedItems[0].index)
        XCTAssertEqual(asset1.localIdentifier, updatedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(2, updatedItems[1].index)
        XCTAssertEqual(asset2.localIdentifier, updatedItems[1].item.assetLocalIdentifier)
    }
    
    func test_updateAtTheEnd_withReversedOrder() {
        
        let asset0 = PHAssetMock()
        let asset1 = PHAssetMock()
        let asset2 = PHAssetMock()
        
        let changes = PHAssetFetchResultChangeDetailsMock(isStrict: false)
        changes.setFetchResultBeforeChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setFetchResultAfterChanges(PHAssetFetchResultMock(assets: [asset0, asset1, asset2]))
        changes.setChangedIndexes([1, 2])
        changes.setChangedObjects([asset1, asset2])
        
        let result = type(of: self).reversedBuilder.photoLibraryChanges(from: changes)
        let updatedItems = result.updatedItems.sorted { $0.index < $1.index }
        
        XCTAssertEqual(2, updatedItems.count)
        
        XCTAssertEqual(0, updatedItems[0].index)
        XCTAssertEqual(asset2.localIdentifier, updatedItems[0].item.assetLocalIdentifier)
        
        XCTAssertEqual(1, updatedItems[1].index)
        XCTAssertEqual(asset1.localIdentifier, updatedItems[1].item.assetLocalIdentifier)
    }
}

private extension PhotoLibraryItem {
    var assetLocalIdentifier: String {
        return (image as! PHAssetImageSource).asset.localIdentifier
    }
}
