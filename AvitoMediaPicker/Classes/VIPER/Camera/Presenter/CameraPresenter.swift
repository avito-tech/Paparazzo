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
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool) {
        interactor.setCameraOutputNeeded(isCameraOutputNeeded)
    }
    
    func isFlashAvailable(completion: Bool -> ()) {
        interactor.isFlashAvailable(completion)
    }
    
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ()) {
        interactor.setFlashEnabled(enabled, completion: completion)
    }
    
    func takePhoto(completion: MediaPickerItem? -> ()) {
        interactor.takePhoto(completion)
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setCameraUnavailableMessageVisible(true)
        
        interactor.onCaptureSessionReady = { [weak self] session in
            self?.view?.setCaptureSession(session)
            self?.view?.setCameraUnavailableMessageVisible(false)
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
    }
}
