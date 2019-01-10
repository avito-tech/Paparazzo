import ImageSource

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    private let deviceOrientationService: DeviceOrientationService
    
    let maxItemsCount: Int?
    let cropCanvasSize: CGSize
    
    private(set) var items = [MediaPickerItem]()
    private var autocorrectionFilters = [Filter]()
    private(set) var photoLibraryItems = [PhotoLibraryItem]()
    private(set) var selectedItem: MediaPickerItem?
    private var mode: MediaPickerCropMode = .normal
    let cameraEnabled: Bool
    let photoLibraryEnabled: Bool
    
    init(
        items: [MediaPickerItem],
        autocorrectionFilters: [Filter],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropCanvasSize: CGSize,
        cameraEnabled: Bool,
        photoLibraryEnabled: Bool,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.items = items
        self.autocorrectionFilters = autocorrectionFilters
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropCanvasSize = cropCanvasSize
        self.cameraEnabled = cameraEnabled
        self.photoLibraryEnabled = photoLibraryEnabled
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
    }
    
    // MARK: - MediaPickerInteractor
    
    func setCropMode(_ mode: MediaPickerCropMode) {
        self.mode = mode
    }
    
    func cropMode() -> MediaPickerCropMode {
        return mode
    }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = handler
        handler(deviceOrientationService.currentOrientation)
    }
    
    func observeLatestPhotoLibraryItem(handler: @escaping (ImageSource?) -> ()) {
        latestLibraryPhotoProvider.observePhoto(handler: handler)
    }
    
    func addItems(
        _ items: [MediaPickerItem]
        ) -> (addedItems: [MediaPickerItem], startIndex: Int)
    {
        let numberOfItemsToAdd = min(items.count, maxItemsCount.flatMap { $0 - self.items.count } ?? Int.max)
        let itemsToAdd = items[0..<numberOfItemsToAdd]
        let startIndex = self.items.count
        self.items.append(contentsOf: itemsToAdd)
        return (Array(itemsToAdd), startIndex)
    }
    
    func addPhotoLibraryItems(
        _ photoLibraryItems: [PhotoLibraryItem]
        ) -> (addedItems: [MediaPickerItem], startIndex: Int)
    {
        
        let mediaPickerItems = photoLibraryItems.map {
            MediaPickerItem(
                image: $0.image,
                source: .photoLibrary
            )
        }
        
        self.photoLibraryItems.append(contentsOf: photoLibraryItems)
        
        return addItems(mediaPickerItems)
    }
    
    func updateItem(_ item: MediaPickerItem) {
        
        if let index = items.index(of: item) {
            items[index] = item
        }
        
        if let selectedItem = selectedItem, item == selectedItem {
            self.selectedItem = item
        }
    }
    
    func removeItem(_ item: MediaPickerItem) -> MediaPickerItem? {
        
        var adjacentItem: MediaPickerItem?
        
        if let index = items.index(of: item) {
        
            items.remove(at: index)
            // TODO: хорошо бы если это фото с камеры, удалять также и файл из папки temp (куда они сейчас складываются)
            
            // Соседним считаем элемент, следующий за удаленным, иначе — предыдущий, если он есть
            if index < items.count {
                adjacentItem = items[index]
            } else if index > 0 {
                adjacentItem = items[index - 1]
            }
        }
        
        if let matchingPhotoLibraryItemIndex = photoLibraryItems.index(where: { $0.image == item.image }) {
            photoLibraryItems.remove(at: matchingPhotoLibraryItemIndex)
        }
        
        return adjacentItem
    }
    
    func selectItem(_ item: MediaPickerItem?) {
        selectedItem = item
    }
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        items.moveElement(from: sourceIndex, to: destinationIndex)
    }
    
    func indexOfItem(_ item: MediaPickerItem) -> Int? {
        return items.index(of: item)
    }
    
    func numberOfItemsAvailableForAdding() -> Int? {
        return maxItemsCount.flatMap { $0 - items.count }
    }
    
    func canAddItems() -> Bool {
        return maxItemsCount.flatMap { self.items.count < $0 } ?? true
    }
    
    func autocorrectItem(
        onResult: @escaping (_ updatedItem: MediaPickerItem?) -> (),
        onError: @escaping (_ errorMessage: String?) -> ())
    {
        guard let originalItem = selectedItem else {
            onError(nil)
            return
        }
        
        var image = originalItem.image
        
        DispatchQueue.global(qos: .userInitiated).async {
            let filtersGroup = DispatchGroup()
            var errorMessages = [String]()
            
            self.autocorrectionFilters.forEach { filter in
                filtersGroup.enter()
                filter.apply(image) { resultItem in
                    let isFilterFailed = resultItem == image
                    if isFilterFailed, let errorMessage = filter.fallbackMessage {
                        errorMessages.append(errorMessage)
                    }
                    
                    image = resultItem
                    filtersGroup.leave()
                }
                filtersGroup.wait()
            }
            
            DispatchQueue.main.async {
                guard image !== originalItem.image else {
                    onError(errorMessages.first)
                    return
                }
                
                let updatedItem = MediaPickerItem(
                    identifier: originalItem.identifier,
                    image: image,
                    source: originalItem.source,
                    originalItem: originalItem
                )
                onResult(updatedItem)
            }
        }
    }
}
