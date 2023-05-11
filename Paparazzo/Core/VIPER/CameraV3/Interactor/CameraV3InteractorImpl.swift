import AVFoundation
import ImageSource

final class CameraV3InteractorImpl: CameraV3Interactor {
    private let mediaPickerData: MediaPickerData
    private let selectedImagesStorage: SelectedImageStorage
    private let cameraService: CameraService
    
    // MARK: - Init
    init(
        mediaPickerData: MediaPickerData,
        selectedImagesStorage: SelectedImageStorage,
        cameraService: CameraService
    ) {
        self.mediaPickerData = mediaPickerData
        self.selectedImagesStorage = selectedImagesStorage
        self.cameraService = cameraService
    }
    
    // MARK: - CameraV3Interactor
    
    var isFlashAvailable: Bool {
        cameraService.isFlashAvailable
    }
    
    var isFlashEnabled: Bool {
         cameraService.isFlashEnabled
    }
    
    var mediaPickerDataWithSelectedLastItem: MediaPickerData {
        mediaPickerData
            .bySettingMediaPickerItems(items)
            .bySelectingLastItem()
    }
    
    var maxItemsCount: Int {
        mediaPickerData.maxItemsCount ?? 0
    }
    
    var canAddNewItems: Bool {
        mediaPickerData.maxItemsCount.flatMap { selectedImagesStorage.images.count < $0 } ?? true
    }
    
    var items: [MediaPickerItem] {
        selectedImagesStorage.images
    }
    
    func addItem(_ item: MediaPickerItem) {
        selectedImagesStorage.addItem(item)
    }
    
    func takePhoto(completion: @escaping (PhotoLibraryItem?) -> ()) {
        cameraService.takePhotoToPhotoLibrary(croppedToRatio: 3.0 / 4.0, completion: completion)
    }
    
    func toggleCamera() {
        cameraService.toggleCamera(completion: { _ in})
    }
    
    func setFlashEnabled(_ isEnabled: Bool) -> Bool {
        cameraService.setFlashEnabled(isEnabled)
    }
    
    func focusCameraOnPoint(_ point: CGPoint) -> Bool {
        cameraService.focusOnPoint(point)
    }
    
    func observeCameraAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        #if targetEnvironment(simulator)
            return handler(true)
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
        selectedImagesStorage.observeImagesChange { [weak self] in
            handler(self?.items.last?.image)
        }
    }
}
