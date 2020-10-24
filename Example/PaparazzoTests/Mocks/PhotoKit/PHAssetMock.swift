import Photos

final class PHAssetMock: PHAsset {
    
    private let mockedLocalIdentifier: String
    private let mockedMediaType: PHAssetMediaType
    
    init(localIdentifier: String = UUID().uuidString, mediaType: PHAssetMediaType = .unknown) {
        mockedLocalIdentifier = localIdentifier
        mockedMediaType = mediaType
    }
    
    // MARK: - PHAsset
    override var localIdentifier: String {
        return mockedLocalIdentifier
    }
    
    override var mediaType: PHAssetMediaType {
        return mockedMediaType
    }
}
