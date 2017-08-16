import ImageSource

final class MediaPickerInteractorImpl: MediaPickerInteractor {
    
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    private let deviceOrientationService: DeviceOrientationService
    
    private let maxItemsCount: Int?
    private let cropCanvasSize: CGSize
    
    private var items = [MediaPickerItem]()
    private var autocorrectionFilters = [Filter]()
    private var photoLibraryItems = [PhotoLibraryItem]()
    private var selectedItem: MediaPickerItem?
    private var mode: MediaPickerCropMode = .normal
    
    init(
        items: [MediaPickerItem],
        autocorrectionFilters: [Filter],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropCanvasSize: CGSize,
        deviceOrientationService: DeviceOrientationService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    ) {
        self.items = items
        self.autocorrectionFilters = autocorrectionFilters
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropCanvasSize = cropCanvasSize
        self.deviceOrientationService = deviceOrientationService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
    }
    
    // MARK: - MediaPickerInteractor
    
    func setCropMode(_ mode: MediaPickerCropMode) {
        self.mode = mode
    }
    
    func cropMode(completion: @escaping (MediaPickerCropMode) -> ()) {
        completion(mode)
    }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = handler
        handler(deviceOrientationService.currentOrientation)
    }
    
    func observeLatestPhotoLibraryItem(handler: @escaping (ImageSource?) -> ()) {
        latestLibraryPhotoProvider.observePhoto(handler: handler)
    }
    
    func addItems(
        _ items: [MediaPickerItem],
        completion: @escaping (_ addedItems: [MediaPickerItem], _ canAddItems: Bool, _ startIndex: Int)
        -> ())
    {
        let numberOfItemsToAdd = min(items.count, maxItemsCount.flatMap { $0 - self.items.count } ?? Int.max)
        let itemsToAdd = items[0..<numberOfItemsToAdd]
        let startIndex = self.items.count
        self.items.append(contentsOf: itemsToAdd)
        completion(Array(itemsToAdd), canAddItems(), startIndex)
    }
    
    func addPhotoLibraryItems(
        _ photoLibraryItems: [PhotoLibraryItem],
        completion: @escaping (_ addedItems: [MediaPickerItem], _ canAddItems: Bool, _ startIndex: Int)
        -> ())
    {
        
        let mediaPickerItems = photoLibraryItems.map {
            MediaPickerItem(
                image: $0.image,
                source: .photoLibrary
            )
        }
        
        self.photoLibraryItems.append(contentsOf: photoLibraryItems)
        
        addItems(mediaPickerItems) { addedItems, canAddMoreItems, startIndex in
            completion(addedItems, canAddMoreItems, startIndex)
        }
    }
    
    func updateItem(_ item: MediaPickerItem, completion: @escaping () -> ()) {
        
        if let index = items.index(of: item) {
            items[index] = item
        }
        
        if let selectedItem = selectedItem, item == selectedItem {
            self.selectedItem = item
        }
        
        completion()
    }
    
    func removeItem(_ item: MediaPickerItem, completion: @escaping (_ adjacentItem: MediaPickerItem?, _ canAddItems: Bool) -> ()) {
        
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
        
        if let matchingPhotoLibraryItemIndex = photoLibraryItems.index(where: { $0.identifier == item.identifier }) {
            photoLibraryItems.remove(at: matchingPhotoLibraryItemIndex)
        }
        
        completion(adjacentItem, canAddItems())
    }
    
    func selectItem(_ item: MediaPickerItem?) {
        selectedItem = item
    }
    
    func selectedItem(completion: @escaping (MediaPickerItem?) -> ()) {
        completion(selectedItem)
    }
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        items.moveElement(from: sourceIndex, to: destinationIndex)
    }
    
    func items(completion: @escaping (_ mediaPickerItems: [MediaPickerItem], _ canAddItems: Bool) -> ()) {
        completion(items, canAddItems())
    }
    
    func photoLibraryItems(completion: @escaping ([PhotoLibraryItem]) -> ()) {
        completion(photoLibraryItems)
    }
    
    func indexOfItem(_ item: MediaPickerItem, completion: @escaping (Int?) -> ()) {
        completion(items.index(of: item))
    }
    
    func numberOfItemsAvailableForAdding(completion: @escaping (Int?) -> ()) {
        completion(maxItemsCount.flatMap { $0 - items.count })
    }
    
    func cropCanvasSize(completion: @escaping (CGSize) -> ()) {
        completion(cropCanvasSize)
    }
    
    func autocorrectItem(completion: @escaping (_ updatedItem: MediaPickerItem?) -> ()) {
        guard let originalItem = selectedItem else {
            completion(nil)
            return
        }
        
        var item = MediaPickerItem(
            identifier: originalItem.identifier,
            image: originalItem.image,
            source: originalItem.source
        )// todo: use image from filters
        
        DispatchQueue.global(qos: .userInitiated).async {
            let filtersGroup = DispatchGroup()
            self.autocorrectionFilters.forEach { filter in
                filtersGroup.enter()
                filter.apply(item) { resultItem in
                    item = resultItem
                    filtersGroup.leave()
                }
                filtersGroup.wait()
            }
            
            filtersGroup.notify(queue: DispatchQueue.main) {
                item.originalItem = originalItem
                completion(item)
            }
        }
    }
    
    // MARK: - Private 
    
    private func canAddItems() -> Bool {
        return maxItemsCount.flatMap { self.items.count < $0 } ?? true
    }
}
