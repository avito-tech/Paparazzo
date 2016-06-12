import Foundation

final class CameraPresenter: CameraModuleInput {
    
    // MARK: - Dependencies
    
    private let interactor: CameraInteractor
//    private let router: MediaPickerRouter
    
    // MARK: - Init
    
    init(interactor: CameraInteractor/*, router: MediaPickerRouter*/) {
        self.interactor = interactor
//        self.router = router
    }
    
    weak var view: CameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Private
    private func setUpView() {
        
        interactor.isFlashAvailable { [weak self] flashAvailable in
            self?.view?.setFlashButtonVisible(flashAvailable)
        }
        
        interactor.onCaptureSessionReady = { [weak self] session in
            self?.view?.setCaptureSession(session)
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
        
        interactor.observeLatestPhotoLibraryItem { [weak self] image in
            self?.view?.setLatestLibraryPhoto(image)
        }
        
        view?.onCameraVisibilityChange = { [weak self] isCameraVisible in
            self?.interactor.setCameraOutputNeeded(isCameraVisible)
        }
        
        view?.onShutterButtonTap = { [weak self] in
            
            self?.view?.animateFlash()
            self?.view?.startSpinnerForNewPhoto()
            
            self?.interactor.takePhoto { photo in
                
                self?.view?.stopSpinnerForNewPhoto()
                
                if let photo = photo {
                    self?.view?.addPhoto(photo)
                }
            }
        }
        
        view?.onFlashToggle = { [weak self] flashEnabled in
            self?.interactor.setFlashEnabled(flashEnabled)
        }
        
        view?.onPhotoSelect = { [weak self] photo in
            self?.view?.setMode(.Preview(photo))
        }
        
        view?.onReturnToCameraTap = { [weak self] in
            self?.view?.removeSelectionInPhotoRibbon()
            self?.view?.setMode(.Capture)
        }
    }
}
