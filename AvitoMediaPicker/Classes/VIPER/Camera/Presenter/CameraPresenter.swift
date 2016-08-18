import AVFoundation

final class CameraPresenter: CameraModuleInput {
    
    private let interactor: CameraInteractor
    
    weak var view: CameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Init
    
    init(interactor: CameraInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - CameraModuleInput
    
    func getCaptureSession(completion: AVCaptureSession? -> ()) {
        interactor.getCaptureSession(completion)
    }
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        interactor.setCameraOutputNeeded(isCameraOutputNeeded)
    }
    
    func isFlashAvailable(completion: Bool -> ()) {
        interactor.isFlashAvailable(completion)
    }
    
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ()) {
        interactor.setFlashEnabled(enabled, completion: completion)
    }
    
    func canToggleCamera(completion: Bool -> ()) {
        interactor.canToggleCamera(completion)
    }
    
    func toggleCamera() {
        interactor.toggleCamera()
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        interactor.takePhoto(completion)
    }
    
    func setPreviewImagesSizeForNewPhotos(size: CGSize) {
        interactor.setPreviewImagesSizeForNewPhotos(size)
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setCameraUnavailableMessageVisible(true)
        
        interactor.getCaptureSession { [weak self] session in
            if let session = session {
                self?.view?.setCaptureSession(session)
                self?.view?.setCameraUnavailableMessageVisible(false)
            }
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
    }
}
