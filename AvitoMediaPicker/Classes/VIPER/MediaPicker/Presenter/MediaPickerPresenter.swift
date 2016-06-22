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
    
    func photoLibraryPickerDidFinishWithItems(photoLibraryItems: [PhotoLibraryItem]) {
        
        let mediaPickerItems = photoLibraryItems.map {
            MediaPickerItem(identifier: $0.identifier, image: $0.image)
        }
        
        addItems(mediaPickerItems)
        
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
            
            // Если фоткать со вспышкой, это занимает много времени, и если несколько раз подряд быстро тапнуть на кнопку,
            // он будет потом еще долго фоткать :) Поэтому временно блокируем кнопку.
            self?.view?.setShutterButtonEnabled(false)
            self?.view?.animateFlash()
            self?.view?.startSpinnerForNewPhoto()
            
            self?.cameraModuleInput.takePhoto { photo in
                
                self?.view?.setShutterButtonEnabled(true)
                self?.view?.stopSpinnerForNewPhoto()
                
                if let photo = photo {
                    self?.addItems([photo])
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
        
        view?.onCloseButtonTap = { [weak self] in
            self?.moduleOutput?.mediaPickerDidCancel()
        }
        
        view?.onContinueButtonTap = { [weak self] in
            self?.interactor.items { items in
                self?.moduleOutput?.mediaPickerDidFinish(withItems: items)
            }
        }
    }
    
    private func addItems(items: [MediaPickerItem]) {
        interactor.addItems(items) { [weak self] in
            self?.view?.addItems(items)
            self?.moduleOutput?.mediaPickerDidAddItems(items)
        }
    }
    
    private func removeItem(item: MediaPickerItem) {
        
        interactor.removeItem(item) { [weak self] adjacentItem in
            
            self?.view?.removeItem(item)
            
            if let adjacentItem = adjacentItem {
                self?.view?.selectItem(adjacentItem)
            } else {
                self?.view?.setMode(.Camera)
            }
            
            self?.moduleOutput?.mediaPickerDidRemoveItem(item)
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
