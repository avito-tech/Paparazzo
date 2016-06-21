protocol MediaPickerInteractor: class {
    
    func addItems(items: [MediaPickerItem], completion: () -> ())
    func removeItem(item: MediaPickerItem, completion: () -> ())
    func numberOfItemsAvailableForAdding(completion: Int? -> ())
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}