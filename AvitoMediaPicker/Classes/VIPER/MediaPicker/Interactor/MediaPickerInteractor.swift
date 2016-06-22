protocol MediaPickerInteractor: class {
    
    func addItems(items: [MediaPickerItem], completion: () -> ())
    
    // `completion` вызывается с соседним item'ом — это item, который нужно выделить после того, как удалили `item`
    func removeItem(item: MediaPickerItem, completion: (adjacentItem: MediaPickerItem?) -> ())
    
    func items(completion: [MediaPickerItem] -> ())
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ())
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}