import AvitoDesignKit

protocol MediaPickerInteractor: class {
    
    func addItems(_: [MediaPickerItem], completion: (addedItems: [MediaPickerItem], canAddItems: Bool) -> ())
    func addPhotoLibraryItems(_: [PhotoLibraryItem], completion: (addedItems: [MediaPickerItem], canAddItems: Bool) -> ())
    
    func updateItem(_: MediaPickerItem, completion: () -> ())
    // `completion` вызывается с соседним item'ом — это item, который нужно выделить после того, как удалили `item`
    func removeItem(_: MediaPickerItem, completion: (adjacentItem: MediaPickerItem?, canAddItems: Bool) -> ())
    
    func selectItem(_: MediaPickerItem)
    func selectedItem(completion: MediaPickerItem? -> ())
    
    func items(completion: (mediaPickerItems: [MediaPickerItem], canAddItems: Bool) -> ())
    func photoLibraryItems(completion: [PhotoLibraryItem] -> ())
    
    func indexOfItem(_: MediaPickerItem, completion: Int? -> ())
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ())
    
    func cropCanvasSize(completion: CGSize -> ())
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}