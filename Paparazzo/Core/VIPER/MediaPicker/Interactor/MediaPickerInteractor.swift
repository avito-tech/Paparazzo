import ImageSource

protocol MediaPickerInteractor: class {
    
    var items: [MediaPickerItem] { get }
    var cropCanvasSize: CGSize { get }
    var cameraEnabled: Bool { get }
    var photoLibraryEnabled: Bool { get }
    var photoLibraryItems: [PhotoLibraryItem] { get }
    var selectedItem: MediaPickerItem? { get }
    var maxItemsCount: Int? { get }
    
    func addItems(
        _ items: [MediaPickerItem]
        ) -> (addedItems: [MediaPickerItem], startIndex: Int)
    func addPhotoLibraryItems(
        _ photoLibraryItems: [PhotoLibraryItem]
        ) -> (addedItems: [MediaPickerItem], startIndex: Int)
    
    func updateItem(_ item: MediaPickerItem)
    
    // returns the nearby item - the item to select after removing the original item
    func removeItem(_ item: MediaPickerItem) -> MediaPickerItem?
    
    func selectItem(_: MediaPickerItem?)
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int)
    
    func indexOfItem(_ item: MediaPickerItem) -> Int?
    
    func numberOfItemsAvailableForAdding() -> Int?
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    func observeLatestPhotoLibraryItem(handler: @escaping (ImageSource?) -> ())
    
    func setCropMode(_: MediaPickerCropMode)
    func cropMode() -> MediaPickerCropMode
    
    func canAddItems() -> Bool
    
    func autocorrectItem(
        onResult: @escaping (_ updatedItem: MediaPickerItem?) -> (),
        onError: @escaping (_ errorMessage: String?) -> ()
    )
}
