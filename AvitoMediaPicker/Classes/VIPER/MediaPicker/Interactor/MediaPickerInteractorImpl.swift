import AvitoDesignKit

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    private let deviceOrientationService: DeviceOrientationService
    
    private let maxItemsCount: Int?
    private let cropCanvasSize: CGSize
    
    private var items = [MediaPickerItem]()
    private var photoLibraryItems = [PhotoLibraryItem]()
    private var selectedItem: MediaPickerItem?
    
    init(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropCanvasSize: CGSize,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.items = items
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropCanvasSize = cropCanvasSize
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
    
    func addPhotoLibraryItems(photoLibraryItems: [PhotoLibraryItem], completion: (mediaPickerItems: [MediaPickerItem], canAddItems: Bool) -> ()) {
        
        let mediaPickerItems = photoLibraryItems.map {
            MediaPickerItem(
                image: $0.image,
                source: .PhotoLibrary
            )
        }
        
        self.photoLibraryItems.appendContentsOf(photoLibraryItems)
        
        addItems(mediaPickerItems) { canAddMoreItems in
            completion(mediaPickerItems: mediaPickerItems, canAddItems: canAddMoreItems)
        }
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
        
        if let matchingPhotoLibraryItemIndex = photoLibraryItems.indexOf({ $0.identifier == item.identifier }) {
            photoLibraryItems.removeAtIndex(matchingPhotoLibraryItemIndex)
        }
        
        completion(adjacentItem: adjacentItem, canAddItems: canAddItems())
    }
    
    func selectItem(item: MediaPickerItem) {
        selectedItem = item
    }
    
    func selectedItem(completion: MediaPickerItem? -> ()) {
        completion(selectedItem)
    }
    
    func items(completion: (mediaPickerItems: [MediaPickerItem], canAddItems: Bool) -> ()) {
        completion(mediaPickerItems: items, canAddItems: canAddItems())
    }
    
    func photoLibraryItems(completion: [PhotoLibraryItem] -> ()) {
        completion(photoLibraryItems)
    }
    
    func indexOfItem(item: MediaPickerItem, completion: Int? -> ()) {
        completion(items.indexOf(item))
    }
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ()) {
        completion(maxItemsCount.flatMap { $0 - items.count })
    }
    
    func cropCanvasSize(completion: CGSize -> ()) {
        completion(cropCanvasSize)
    }
    
    // MARK: - Private 
    
    private func canAddItems() -> Bool {
        return maxItemsCount.flatMap { self.items.count < $0 } ?? true
    }
}
