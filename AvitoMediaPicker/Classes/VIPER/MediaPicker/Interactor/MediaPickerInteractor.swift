protocol MediaPickerInteractor: class {
    
    func addPhotoLibraryItems(items: [AnyObject], completion: ())
    func removeItem(item: MediaPickerItem)
    func numberOfItemsAvailableForAdding(completion: Int? -> ())
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}