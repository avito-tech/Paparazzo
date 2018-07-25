import Photos

final class PHAssetFetchResultChangeDetailsMock: PHFetchResultChangeDetails<PHAsset> {
    
    private let isStrict: Bool
    private var mockedFetchResultBeforeChanges: PHAssetFetchResultMock?
    private var mockedFetchResultAfterChanges: PHAssetFetchResultMock?
    private var mockedRemovedIndexes: IndexSet??
    private var mockedRemovedObjects: [PHAssetMock]?
    private var mockedInsertedIndexes: IndexSet??
    private var mockedInsertedObjects: [PHAssetMock]?
    private var mockedChangedIndexes: IndexSet??
    private var mockedChangedObjects: [PHAssetMock]?
    private var mockedMoves: [(Int, Int)]?
    
    /**
     Strict mock will fail if method is being called for which mock value hasn't been provided by the user.
     If mock is not strict, it will try to substitude default values for such calls whenever possible.
     */
    init(isStrict: Bool) {
        self.isStrict = isStrict
    }
    
    // MARK: - Setting mock values
    func setFetchResultBeforeChanges(_ fetchResultBeforeChanges: PHAssetFetchResultMock) {
        mockedFetchResultBeforeChanges = fetchResultBeforeChanges
    }
    
    func setFetchResultAfterChanges(_ fetchResultAfterChanges: PHAssetFetchResultMock) {
        mockedFetchResultAfterChanges = fetchResultAfterChanges
    }
    
    func setRemovedIndexes(_ removedIndexes: IndexSet?) {
        mockedRemovedIndexes = removedIndexes
    }
    
    func setRemovedObjects(_ removedObjects: [PHAssetMock]) {
        mockedRemovedObjects = removedObjects
    }
    
    func setInsertedIndexes(_ insertedIndexes: IndexSet?) {
        mockedInsertedIndexes = insertedIndexes
    }
    
    func setInsertedObjects(_ insertedObjects: [PHAssetMock]) {
        mockedInsertedObjects = insertedObjects
    }
    
    func setChangedIndexes(_ changedIndexes: IndexSet?) {
        mockedChangedIndexes = changedIndexes
    }
    
    func setChangedObjects(_ changedObjects: [PHAssetMock]) {
        mockedChangedObjects = changedObjects
    }
    
    func setMoves(_ moves: [(Int, Int)]) {
        mockedMoves = moves
    }
    
    // MARK: - PHFetchResultChangeDetails
    override var fetchResultBeforeChanges: PHFetchResult<PHAsset> {
        if let mockedFetchResultBeforeChanges = mockedFetchResultBeforeChanges {
            return mockedFetchResultBeforeChanges
        } else if isStrict {
            fatalError("`fetchResultBeforeChanges` is not mocked. Call `setFetchResultBeforeChanges(_:)` first.")
        } else {
            return PHAssetFetchResultMock(assets: [])
        }
    }
    
    override var fetchResultAfterChanges: PHFetchResult<PHAsset> {
        if let mockedFetchResultAfterChanges = mockedFetchResultAfterChanges {
            return mockedFetchResultAfterChanges
        } else if isStrict {
            fatalError("`fetchResultAfterChanges` is not mocked. Call `setFetchResultAfterChanges(_:)` first.")
        } else {
            return PHAssetFetchResultMock(assets: [])
        }
    }
    
    override var hasIncrementalChanges: Bool {
        fatalError("`hasIncrementalChanges` is not mocked. Call `setHasIncrementalChanges(_:)` first.")
    }
    
    override var removedIndexes: IndexSet? {
        if let mockedRemovedIndexes = mockedRemovedIndexes {
            return mockedRemovedIndexes
        } else if isStrict {
            fatalError("`removedIndexes` is not mocked. Call `setRemovedIndexes(_:)` first.")
        } else {
            return nil
        }
    }
    
    override var removedObjects: [PHAsset] {
        if let mockedRemovedObjects = mockedRemovedObjects {
            return mockedRemovedObjects
        } else if isStrict {
            fatalError("`removedObjects` is not mocked. Call `setRemovedObjects(_:)` first.")
        } else {
            return []
        }
    }
    
    override var insertedIndexes: IndexSet? {
        if let mockedInsertedIndexes = mockedInsertedIndexes {
            return mockedInsertedIndexes
        } else if isStrict {
            fatalError("`insertedIndexes` is not mocked. Call `setInsertedIndexes(_:)` first.")
        } else {
            return nil
        }
    }
    
    override var insertedObjects: [PHAsset] {
        if let mockedInsertedObjects = mockedInsertedObjects {
            return mockedInsertedObjects
        } else if isStrict {
            fatalError("`insertedObjects` is not mocked. Call `setInsertedObjects(_:)` first.")
        } else {
            return []
        }
    }
    
    override var changedIndexes: IndexSet? {
        if let mockedChangedIndexes = mockedChangedIndexes {
            return mockedChangedIndexes
        } else if isStrict {
            fatalError("`changedIndexes` is not mocked. Call `setChangedIndexes(_:)` first.")
        } else {
            return nil
        }
    }
    
    override var changedObjects: [PHAsset] {
        if let mockedChangedObjects = mockedChangedObjects {
            return mockedChangedObjects
        } else if isStrict {
            fatalError("`changedObjects` is not mocked. Call `setChangedObjects(_:)` first.")
        } else {
            return []
        }
    }
    
    override func enumerateMoves(_ handler: @escaping (Int, Int) -> Void) {
        if let mockedMoves = mockedMoves {
            mockedMoves.forEach { from, to in
                handler(from, to)
            }
        } else if isStrict {
            fatalError("`enumerateMoves(_:)` is not mocked. Call `setMoves(_:)` first.")
        } else {
            // Nothing to enumerate
        }
    }
    
    override var hasMoves: Bool {
        fatalError("`hasMoves` is not mocked. Call `setHasMoves(_:)` first.")
    }
}
