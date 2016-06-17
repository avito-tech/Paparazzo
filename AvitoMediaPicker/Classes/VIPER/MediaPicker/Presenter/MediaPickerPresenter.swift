final class MediaPickerPresenter: MediaPickerModuleInput, PhotoLibraryModuleOutput, ImageCroppingModuleOutput {
    
    // MARK: - Dependencies
    
    private let interactor: MediaPickerInteractor
    private let router: MediaPickerRouter
    private let cameraModuleInput: CameraModuleInput

    weak var moduleOutput: MediaPickerModuleOutput?
    
    // MARK: - Init
    
    init(interactor: MediaPickerInteractor, router: MediaPickerRouter, cameraModuleInput: CameraModuleInput) {
        self.interactor = interactor
        self.router = router
        self.cameraModuleInput = cameraModuleInput
    }
    
    weak var view: MediaPickerViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - PhotoLibraryModuleOutput
    
    func photoLibraryPickerDidFinishWithItems(selectedItems: [PhotoLibraryItem]) {
        // TODO
        print("photoLibraryPickerDidFinishWithItems: \(selectedItems)")
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        // TODO: move to viewDidLoad and check cameraModuleInput for nullability
        cameraModuleInput.isFlashAvailable { [weak self] flashAvailable in
            self?.view?.setFlashButtonVisible(flashAvailable)
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
        
        interactor.observeLatestPhotoLibraryItem { [weak self] image in
            self?.view?.setLatestLibraryPhoto(image)
        }
        
        view?.onCameraVisibilityChange = { [weak self] isCameraVisible in
            self?.cameraModuleInput.setCameraOutputNeeded(isCameraVisible)
        }
        
        view?.onPhotoLibraryButtonTap = { [weak self] in
            self?.showPhotoLibrary()
        }
        
        view?.onShutterButtonTap = { [weak self] in
            
            self?.view?.animateFlash()
            self?.view?.startSpinnerForNewPhoto()
            
            self?.cameraModuleInput.takePhoto { photo in
                
                self?.view?.stopSpinnerForNewPhoto()
                
                if let photo = photo {
                    self?.view?.addPhotoRibbonItem(photo)
                }
            }
        }
        
        view?.onFlashToggle = { [weak self] shouldEnableFlash in
            self?.cameraModuleInput.setFlashEnabled(shouldEnableFlash) { success in
                if !success {
                    self?.view?.setFlashButtonOn(!shouldEnableFlash)
                }
            }
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
    
    // MARK: - Private
    
    private func showPhotoLibrary() {
        interactor.numberOfItemsAvailableForAdding { [weak self] maxItemsCount in
            guard let strongSelf = self else { return }
            strongSelf.router.showPhotoLibrary(maxItemsCount: maxItemsCount, moduleOutput: strongSelf)
        }
    }
    
    private func showCroppingModule() {
        let photo = NSNumber()  // TODO
        router.showCroppingModule(photo: photo, moduleOutput: self)
    }
}
