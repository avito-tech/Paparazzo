import ImageSource

protocol CameraV3Interactor: AnyObject {
    var isFlashAvailable: Bool { get }
    var isFlashEnabled: Bool { get }
    var canAddNewItems: Bool { get }
    var maxItemsCount: Int { get }
    var items: [MediaPickerItem] { get }
    var mediaPickerDataWithSelectedLastItem: MediaPickerData { get }
    
    func toggleCamera()
    func setFlashEnabled(_ isEnabled: Bool) -> Bool
    func focusCameraOnPoint(_ point: CGPoint) -> Bool
    func takePhoto(completion: @escaping (PhotoLibraryItem?) -> ())
    func addItem(_ item: MediaPickerItem)
    func observeCameraAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeLatestLibraryPhoto(handler: @escaping (ImageSource?) -> ())
}
