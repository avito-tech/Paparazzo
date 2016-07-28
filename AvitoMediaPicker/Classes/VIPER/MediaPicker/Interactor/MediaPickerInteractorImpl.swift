final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    private let deviceOrientationService: DeviceOrientationService
    
    private let maxItemsCount: Int?
    private var items = [MediaPickerItem]()
    private var selectedItem: MediaPickerItem?
    
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
    
    func addItems(items: [MediaPickerItem], completion: (canAddItems: Bool) -> ()) {
        self.items.appendContentsOf(items)
        completion(canAddItems: canAddItems())
    }
    
    func updateItem(item: MediaPickerItem, completion: () -> ()) {
        
        if let index = items.indexOf(item) {
            items[index] = item
        }
        
        if let selectedItem = selectedItem where item == selectedItem {
            self.selectedItem = item
        }
        
        completion()
    }
    
    func removeItem(item: MediaPickerItem, completion: (adjacentItem: MediaPickerItem?, canAddItems: Bool) -> ()) {
        
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
        
        completion(adjacentItem: adjacentItem, canAddItems: canAddItems())
    }
    
    func selectItem(item: MediaPickerItem) {
        selectedItem = item
    }
    
    func selectedItem(completion: MediaPickerItem? -> ()) {
        completion(selectedItem)
    }
    
    func items(completion: [MediaPickerItem] -> ()) {
        completion(items)
    }
    
    func indexOfItem(item: MediaPickerItem, completion: Int? -> ()) {
        completion(items.indexOf(item))
    }
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ()) {
        completion(maxItemsCount.flatMap { $0 - items.count })
    }
    
    // MARK: - Private 
    
    private func canAddItems() -> Bool {
        return maxItemsCount.flatMap { self.items.count < $0 } ?? true
    }
}
