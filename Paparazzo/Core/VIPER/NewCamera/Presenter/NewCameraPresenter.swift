final class NewCameraPresenter:
    NewCameraModule
{
    // MARK: - Dependencies
    private let interactor: NewCameraInteractor
    private let router: NewCameraRouter
    
    // MARK: - Config
    private let shouldAllowFinishingWithNoPhotos: Bool
    
    // MARK: - Init
    init(
        interactor: NewCameraInteractor,
        router: NewCameraRouter,
        shouldAllowFinishingWithNoPhotos: Bool)
    {
        self.interactor = interactor
        self.router = router
        self.shouldAllowFinishingWithNoPhotos = shouldAllowFinishingWithNoPhotos
    }
    
    // MARK: - Weak properties
    weak var view: NewCameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - NewCameraModule
    var onFinish: ((NewCameraModule, NewCameraModuleResult) -> ())?
    var configureMediaPicker: ((MediaPickerModule) -> ())?
    
    func focusOnModule() {
        router.focusOnCurrentModule()
    }
    
    // MARK: - Private
    private func setUpView() {
        
        view?.setFlashButtonVisible(interactor.isFlashAvailable)
        view?.setFlashButtonOn(interactor.isFlashEnabled)
        
        view?.setDoneButtonTitle(localized("Done"))
        view?.setPlaceholderText(localized("Select at least one photo"))
        view?.setHintText(localized("Place the object inside the frame and take a photo"))
        
        view?.onCloseButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            self?.onFinish?(strongSelf, .cancelled)
        }
        
        view?.onDoneButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            self?.onFinish?(strongSelf, .finished)
        }
        
        view?.onLastPhotoThumbnailTap = { [weak self] in
            guard
                let strongSelf = self,
                let selectedItems = self?.interactor.selectedImagesStorage.images
            else { return }
            
            let data = strongSelf.interactor.mediaPickerData
                .bySettingPhotoLibraryItems(selectedItems)
                .bySelectingLastItem()
            
            self?.router.showMediaPicker(
                data: data,
                overridenTheme: nil,
                configure: { module in
                    self?.configureMediaPicker?(module)
                }
            )
        }
        
        view?.onToggleCameraButtonTap = { [weak self] in
            self?.interactor.toggleCamera { _ in }
        }
        
        view?.onFlashToggle = { [weak self] isFlashEnabled in
            guard let strongSelf = self else { return }
            
            if !strongSelf.interactor.setFlashEnabled(isFlashEnabled) {
                strongSelf.view?.setFlashButtonOn(!isFlashEnabled)
            }
        }
        
        view?.onCaptureButtonTap = { [weak self] in
            self?.view?.setCaptureButtonState(.nonInteractive)
            self?.view?.animateFlash()
            
            self?.interactor.takePhoto { photo in
                guard let photo = photo, let strongSelf = self else { return }
                
                self?.interactor.selectedImagesStorage.addItem(photo)
                self?.adjustCaptureButtonAvailability()
                
                self?.view?.animateCapturedPhoto(photo.image) { finalizeAnimation in
                    self?.adjustSelectedPhotosBar {
                        finalizeAnimation()
                    }
                }
            }
        }
        
        bindSelectedPhotosBarAdjustmentToViewControllerLifecycle()
        adjustCaptureButtonAvailability()
        
        interactor.observeLatestLibraryPhoto { [weak self] imageSource in
            self?.view?.setLatestPhotoLibraryItemImage(imageSource)
        }
    }
    
    private func bindSelectedPhotosBarAdjustmentToViewControllerLifecycle() {
        var didDisappear = false
        var viewDidLayoutSubviewsBefore = false
        
        view?.onViewWillAppear = { _ in
            guard didDisappear else { return }
            
            DispatchQueue.main.async {
                self.adjustSelectedPhotosBar {}
            }
        }
        
        view?.onViewDidDisappear = { _ in
            didDisappear = true
        }
        
        view?.onViewDidLayoutSubviews = {
            guard !viewDidLayoutSubviewsBefore else { return }
            
            DispatchQueue.main.async {
                self.adjustSelectedPhotosBar {}
            }
            
            viewDidLayoutSubviewsBefore = true
        }
    }
    
    private func adjustSelectedPhotosBar(completion: @escaping () -> ()) {
        
        let images = interactor.selectedImagesStorage.images
        
        let state: SelectedPhotosBarState = images.isEmpty
            ? (shouldAllowFinishingWithNoPhotos ? .placeholder : .hidden)
            : .visible(SelectedPhotosBarData(
                lastPhoto: images.last?.image,
                penultimatePhoto: images.count > 1 ? images[images.count - 2].image : nil,
                countString: "\(images.count) фото"
            ))
        
        view?.setSelectedPhotosBarState(state, completion: completion)
    }
    
    private func adjustCaptureButtonAvailability() {
        view?.setCaptureButtonState(interactor.canAddItems() ? .enabled : .disabled)
    }
}
