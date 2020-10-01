import AVFoundation
import ImageSource

final class NewCameraInteractorImpl: NewCameraInteractor {
    
    // MARK: - Dependencies
    private let cameraService: CameraService
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    
    // MARK: - Init
    init(
        mediaPickerData: MediaPickerData,
        selectedImagesStorage: SelectedImageStorage,
        cameraService: CameraService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider)
    {
        self.mediaPickerData = mediaPickerData
        self.selectedImagesStorage = selectedImagesStorage
        self.cameraService = cameraService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
    }
    
    // MARK: - NewCameraInteractor
    let mediaPickerData: MediaPickerData
    let selectedImagesStorage: SelectedImageStorage
    
    var isFlashAvailable: Bool {
        return cameraService.isFlashAvailable
    }
    
    var isFlashEnabled: Bool {
        return cameraService.isFlashEnabled
    }
    
    func observeCameraAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        #if targetEnvironment(simulator)
            return handler(false)
        #endif
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            handler(true)
        case .notDetermined, .denied, .restricted:
            handler(false)
        @unknown default:
            assertionFailure("Unknown authorization status")
            handler(false)
        }
    }
    
    func observeLatestLibraryPhoto(handler: @escaping (ImageSource?) -> ()) {
        latestLibraryPhotoProvider.observePhoto(handler: handler)
    }
    
    func toggleCamera(completion: @escaping (ExifOrientation) -> ()) {
        cameraService.toggleCamera(completion: completion)
    }
    
    func setFlashEnabled(_ isEnabled: Bool) -> Bool {
        return cameraService.setFlashEnabled(isEnabled)
    }
    
    func takePhoto(completion: @escaping (PhotoLibraryItem?) -> ()) {
        cameraService.takePhotoToPhotoLibrary(croppedToRatio: 4.0 / 3.0, completion: completion)
    }
    
    func canAddItems() -> Bool {
        return mediaPickerData.maxItemsCount.flatMap { self.selectedImagesStorage.images.count < $0 } ?? true
    }
}
