import Foundation

final class MediaPickerPresenter: MediaPickerModuleInput, PhotoLibraryModuleOutput, ImageCroppingModuleOutput {
    
    // MARK: - Dependencies
    
    private let interactor: MediaPickerInteractor
    private let router: MediaPickerRouter

    weak var moduleOutput: MediaPickerModuleOutput?
    
    // MARK: - Init
    
    init(interactor: MediaPickerInteractor, router: MediaPickerRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    weak var view: MediaPickerViewInput? {
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
        
        view?.onPhotoLibraryButtonTap = { [weak self] in
            self?.showPhotoLibrary()
        }
        
        view?.onShutterButtonTap = { [weak self] in
            
            self?.view?.animateFlash()
            self?.view?.startSpinnerForNewPhoto()
            
            self?.interactor.takePhoto { photo in
                
                self?.view?.stopSpinnerForNewPhoto()
                
                if let photo = photo {
                    self?.view?.addPhotoRibbonItem(photo)
                }
            }
        }
        
        view?.onFlashToggle = { [weak self] flashEnabled in
            self?.interactor.setFlashEnabled(flashEnabled)
        }
        
        view?.onPhotoSelect = { [weak self] photo in
            self?.view?.setMode(.PhotoPreview(photo))
        }
        
        view?.onRemoveButtonTap = {
            // TODO
            print("onRemoveButtonTap")
        }
        
        view?.onCropButtonTap = { [weak self] in
            self?.showCroppingModule()
        }
        
        view?.onReturnToCameraTap = { [weak self] in
            self?.view?.removeSelectionInPhotoRibbon()
            self?.view?.setMode(.Camera)
        }
    }
    
    // MARK: - PhotoLibraryModuleOutput
    
    // TODO
    
    // MARK: - Private
    
    private func showPhotoLibrary() {
        router.showPhotoLibrary(moduleOutput: self)
    }
    
    private func showCroppingModule() {
        let photo = NSNumber()  // TODO
        router.showCroppingModule(photo: photo, moduleOutput: self)
    }
}
