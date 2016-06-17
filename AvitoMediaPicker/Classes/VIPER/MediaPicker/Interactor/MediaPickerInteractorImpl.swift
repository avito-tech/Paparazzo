import Foundation
import AVFoundation

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    private let deviceOrientationService: DeviceOrientationService
    
    private let maxItemsCount: Int?
    private var items = [MediaPickerItem]()
    
    init(
        maxItemsCount: Int?,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.maxItemsCount = maxItemsCount
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
    }
    
    // MARK: - MediaPickerInteractor
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?) {
        deviceOrientationService.onOrientationChange = handler
        handler?(deviceOrientationService.currentOrientation)
    }
    
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?) {
        latestLibraryPhotoProvider.observePhoto(handler)
    }
    
    func addPhotoLibraryItems(items: [AnyObject], completion: ()) {
        // TODO
    }
    
    func removeItem(item: MediaPickerItem) {
        // TODO
    }
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ()) {
        completion(maxItemsCount.flatMap { $0 - items.count })
    }
}
