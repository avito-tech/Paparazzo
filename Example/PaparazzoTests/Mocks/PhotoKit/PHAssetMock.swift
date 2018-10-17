import Photos

final class PHAssetMock: PHAsset {
    
    private let mockedLocalIdentifier: String
    
    init(localIdentifier: String = UUID().uuidString) {
        mockedLocalIdentifier = localIdentifier
    }
    
    // MARK: - PHAsset
    override var localIdentifier: String {
        return mockedLocalIdentifier
    }
}
