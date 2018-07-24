import Photos

final class PHAssetFetchResultMock: PHFetchResult<PHAsset> {
    
    private let assets: [PHAssetMock]
    
    init(assets: [PHAssetMock]) {
        self.assets = assets
    }
    
    // MARK: - PHFetchResult
    override var count: Int {
        return assets.count
    }
    
    override func object(at index: Int) -> PHAsset {
        return assets[index]
    }
    
    override subscript(idx: Int) -> PHAsset {
        get { return object(at: idx) }
    }
    
    override func contains(_ asset: PHAsset) -> Bool {
        return assets.contains { $0.localIdentifier == asset.localIdentifier }
    }
    
    override func index(of asset: PHAsset) -> Int {
        return assets.index { $0.localIdentifier == asset.localIdentifier } ?? NSNotFound
    }
    
    override func index(of asset: PHAsset, in range: NSRange) -> Int {
        fatalError("Not implemented")
    }
    
    override var firstObject: PHAsset? {
        return assets.first
    }
    
    override var lastObject: PHAsset? {
        return assets.last
    }
    
    override func objects(at indexes: IndexSet) -> [PHAsset] {
        return indexes.map { assets[$0] }
    }
    
    override func enumerateObjects(_ block: @escaping (PHAsset, Int, UnsafeMutablePointer<ObjCBool>) -> ()) {
        (assets as NSArray).enumerateObjects { _, index, shouldStop in
            block(assets[index], index, shouldStop)
        }
    }
    
    override func enumerateObjects(
        options: NSEnumerationOptions = [],
        using block: @escaping (PHAsset, Int, UnsafeMutablePointer<ObjCBool>) -> ())
    {
        (assets as NSArray).enumerateObjects(options: options) { _, index, shouldStop in
            block(assets[index], index, shouldStop)
        }
    }
    
    override func enumerateObjects(
        at indexes: IndexSet,
        options: NSEnumerationOptions = [],
        using block: @escaping (PHAsset, Int, UnsafeMutablePointer<ObjCBool>) -> Void)
    {
        (assets as NSArray).enumerateObjects(at: indexes, options: options) { _, index, shouldStop in
            block(assets[index], index, shouldStop)
        }
    }
    
    override func countOfAssets(with mediaType: PHAssetMediaType) -> Int {
        return assets.filter { $0.mediaType == mediaType }.count
    }
}
