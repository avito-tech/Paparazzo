import Photos

protocol PhotoLibraryItemsService {
    var authorizationStatus: PHAuthorizationStatus { get }
    func observePhotos(handler: (_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ())
}

final class PhotoLibraryItemsServiceImpl: NSObject, PhotoLibraryItemsService, PHPhotoLibraryChangeObserver {

    private let photoLibrary = PHPhotoLibrary.shared()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    // MARK: - Init
    
    override init() {
        super.init()
        
        photoLibrary.register(self)
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            setUpFetchRequest()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if case .authorized = status {
                    self?.setUpFetchRequest()
                }
            }
        case .restricted, .denied:
            break
        }
    }
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    // MARK: - PhotoLibraryItemsService
    
    private var observerHandler: ((_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ())?
    
    var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    func observePhotos(handler: @escaping (_ assets: [PHAsset], _ changes: PHFetchResultChangeDetails<PHAsset>?) -> ()) {
        observerHandler = handler
        callObserverHandler(changes: nil)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInfo: PHChange) {
        DispatchQueue.main.async {
            if let fetchResult = self.fetchResult, let changes = changeInfo.changeDetails(for: fetchResult) {
                debugPrint("photoLibraryDidChange")
                self.fetchResult = changes.fetchResultAfterChanges
                self.callObserverHandler(changes: changes)
            }
        }
    }

    // MARK: - Private
    
    private func setUpFetchRequest() {
        
        // Сначала пытаемся найти альбом Camera Roll
        let albums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        albums.enumerateObjects { collection, _, stop in
            self.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            // Camera Roll должен идти самым первым, поэтому дальше не продолжаем
            stop.memory = ObjCBool(true)
        }
        
        // Fallback на случай, если по какой-то причине не нашли альбом Camera Roll
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: .image, options: nil)
        }
        
        callObserverHandler(changes: nil)
    }

    private func callObserverHandler(changes: PHFetchResultChangeDetails?) {
        observerHandler?(assets: assetsFromFetchResult(), changes: changes)
    }
    
    private func assetsFromFetchResult() -> [PHAsset] {
        var images = [PHAsset]()
        fetchResult?.enumerateObjects { asset, _, _ in
            images.append(asset)
        }
        return images
    }
}
