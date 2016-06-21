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
    
    func addItems(items: [MediaPickerItem], completion: () -> ()) {
        self.items.appendContentsOf(items)
        completion()
    }
    
    func removeItem(item: MediaPickerItem, completion: (adjacentItem: MediaPickerItem?) -> ()) {
        
        var adjacentItem: MediaPickerItem?
        
        if let index = items.indexOf(item) {
        
            items.removeAtIndex(index)
            // TODO: хорошо бы если это фото с камеры, удалять также и файл из папки temp (куда они сейчас складываются)
            
            // Соседним считаем элемент, следующий за удаленным, иначе — предыдущий, если он есть
            if index < items.count {
                adjacentItem = items[index]
            } else if index > 0 {
                adjacentItem = items[index - 1]
            }
        }
        
        completion(adjacentItem: adjacentItem)
    }
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ()) {
        completion(maxItemsCount.flatMap { $0 - items.count })
    }
}
