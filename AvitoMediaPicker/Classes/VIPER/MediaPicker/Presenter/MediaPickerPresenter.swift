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
        
        selectedItems.forEach { item in
            self.view?.addItem(MediaPickerItem(image: item.image))
        }
        
        router.focusOnCurrentModule()
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setContinueButtonTitle("Далее")
        
        cameraModuleInput.getCaptureSession { [weak self] captureSession in
            if let captureSession = captureSession {
                self?.view?.setCaptureSession(captureSession)
            }
        }
        
        cameraModuleInput.isFlashAvailable { [weak self] flashAvailable in
            self?.view?.setFlashButtonVisible(flashAvailable)
        }
        
        cameraModuleInput.canToggleCamera { [weak self] canToggleCamera in
            self?.view?.setCameraToggleButtonVisible(canToggleCamera)
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
        
        interactor.observeLatestPhotoLibraryItem { [weak self] image in
            self?.view?.setLatestLibraryPhoto(image)
        }
        
        view?.onCameraVisibilityChange = { [weak self] isCameraVisible in
            // TODO: этот метод должен теперь вызываться и тогда, когда слот камеры в ленте фоток появляется/исчезает
//            self?.cameraModuleInput.setCameraOutputNeeded(isCameraVisible)
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
                    self?.interactor.addItems([photo]) {
                        self?.view?.addItem(photo)
                    }
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
        
        view?.onItemSelect = { [weak self] item in
            self?.view?.setMode(.PhotoPreview(item))
            self?.view?.onRemoveButtonTap = {
                self?.removeItem(item)
            }
        }
        
        view?.onCropButtonTap = { [weak self] in
            self?.showCroppingModule()
        }
        
        view?.onReturnToCameraTap = { [weak self] in
            self?.view?.setMode(.Camera)
        }
        
        view?.onCameraToggleButtonTap = { [weak self] in
            self?.cameraModuleInput.toggleCamera()
        }
    }
    
    // MARK: - Private
    
    private func removeItem(item: MediaPickerItem) {
        
        interactor.removeItem(item) { [weak self] adjacentItem in
            
            self?.view?.removeItem(item)
            
            if let adjacentItem = adjacentItem {
                self?.view?.selectItem(adjacentItem)
            } else {
                self?.view?.setMode(.Camera)
            }
        }
    }
    
    private func showPhotoLibrary() {
        interactor.numberOfItemsAvailableForAdding { [weak self] maxItemsCount in
            guard let strongSelf = self else { return }
            strongSelf.router.showPhotoLibrary(maxItemsCount: maxItemsCount, moduleOutput: strongSelf)
        }
    }
    
    private func showCroppingModule() {
        // TODO
//        router.showCroppingModule(photo: photo, moduleOutput: self)
    }
}
