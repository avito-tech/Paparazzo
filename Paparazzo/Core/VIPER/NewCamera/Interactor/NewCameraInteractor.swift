import ImageSource

protocol NewCameraInteractor: class {
    var mediaPickerData: MediaPickerData { get }
    var selectedImagesStorage: SelectedImageStorage { get }
    var isFlashAvailable: Bool { get }
    var isFlashEnabled: Bool { get }
    
    func observeLatestLibraryPhoto(handler: @escaping (ImageSource?) -> ())
    func toggleCamera(completion: @escaping (ExifOrientation) -> ())
    func setFlashEnabled(_ isEnabled: Bool) -> Bool
    func takePhoto(completion: @escaping (PhotoLibraryItem?) -> ())
    func canAddItems() -> Bool
}
