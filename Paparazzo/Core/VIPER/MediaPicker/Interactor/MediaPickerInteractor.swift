import ImageSource

protocol MediaPickerInteractor: class {
    
    func addItems(_: [MediaPickerItem], completion: @escaping (_ addedItems: [MediaPickerItem], _ canAddItems: Bool) -> ())
    func addPhotoLibraryItems(_: [PhotoLibraryItem], completion: @escaping (_ addedItems: [MediaPickerItem], _ canAddItems: Bool) -> ())
    
    func updateItem(_: MediaPickerItem, completion: @escaping () -> ())
    // `completion` вызывается с соседним item'ом — это item, который нужно выделить после того, как удалили `item`
    func removeItem(_: MediaPickerItem, completion: @escaping (_ adjacentItem: MediaPickerItem?, _ canAddItems: Bool) -> ())
    
    func selectItem(_: MediaPickerItem?)
    func selectedItem(completion: @escaping (MediaPickerItem?) -> ())
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int)
    
    func items(completion: @escaping (_ mediaPickerItems: [MediaPickerItem], _ canAddItems: Bool) -> ())
    func photoLibraryItems(completion: @escaping ([PhotoLibraryItem]) -> ())
    
    func indexOfItem(_: MediaPickerItem, completion: @escaping (Int?) -> ())
    
    func numberOfItemsAvailableForAdding(completion: @escaping (Int?) -> ())
    
    func cropCanvasSize(completion: @escaping (CGSize) -> ())
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    func observeLatestPhotoLibraryItem(handler: @escaping (ImageSource?) -> ())
}
