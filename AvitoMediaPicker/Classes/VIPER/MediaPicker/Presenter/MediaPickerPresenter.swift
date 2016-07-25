final class MediaPickerPresenter: MediaPickerModule {
    
    // MARK: - Dependencies
    
    private let interactor: MediaPickerInteractor
    private let router: MediaPickerRouter
    private let cameraModuleInput: CameraModuleInput
    
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
    
    // MARK: - MediaPickerModule

    var onItemsAdd: ([MediaPickerItem] -> ())?
    var onItemUpdate: (MediaPickerItem -> ())?
    var onItemRemove: (MediaPickerItem -> ())?
    var onFinish: ([MediaPickerItem] -> ())?
    var onCancel: (() -> ())?

    // MARK: - Private
    
    private func setUpView() {
        
        view?.setContinueButtonTitle("Далее")
        view?.setPhotoTitle("Фото 1")
        
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
        
        view?.onPhotoLibraryButtonTap = { [weak self] in
            self?.showPhotoLibrary()
        }
        
        view?.onShutterButtonTap = { [weak self] in
            
            // Если фоткать со вспышкой, это занимает много времени, и если несколько раз подряд быстро тапнуть на кнопку,
            // он будет потом еще долго фоткать :) Поэтому временно блокируем кнопку.
            self?.view?.setShutterButtonEnabled(false)
            self?.view?.animateFlash()
            
            self?.cameraModuleInput.takePhoto { photo in
                
                self?.view?.setShutterButtonEnabled(true)
                
                if let photo = photo {
                    self?.addItems([photo.toItemWithCachingImageSource()], fromCamera: true)
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
            
            self?.adjustPhotoTitleForItem(item)
            
            self?.view?.setMode(.PhotoPreview(item))
            self?.view?.scrollToItemThumbnail(item, animated: true)
            
            self?.view?.onRemoveButtonTap = {
                self?.removeItem(item)
            }
            
            self?.view?.onCropButtonTap = {
                self?.showCroppingModule(forItem: item)
            }
        }
        
        view?.onCameraThumbnailTap = { [weak self] in
            self?.view?.setMode(.Camera)
            self?.view?.scrollToCameraThumbnail(animated: true)
        }
        
        view?.onCameraToggleButtonTap = { [weak self] in
            self?.cameraModuleInput.toggleCamera()
        }
        
        view?.onSwipeToItem = { [weak self] item in
            self?.view?.selectItem(item)
        }
        
        view?.onSwipeToCamera = { [weak self] in
            self?.view?.selectCamera()
        }
        
        view?.onSwipeToCameraProgressChange = { [weak self] progress in
            self?.view?.setPhotoTitleAlpha(1 - progress)
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.onCancel?()
        }
        
        view?.onContinueButtonTap = { [weak self] in
            self?.interactor.items { items in
                self?.onFinish?(items)
            }
        }
    }
    
    private func adjustPhotoTitleForItem(item: MediaPickerItem) {
        interactor.indexOfItem(item) { [weak self] index in
            if let index = index {
                self?.view?.setPhotoTitle("Фото \(index + 1)")
            }
        }
    }
    
    private func addItems(items: [MediaPickerItem], fromCamera: Bool) {
        
        interactor.addItems(items) { [weak self] canAddItems in
            
            self?.view?.addItems(items, animated: fromCamera)
            self?.view?.setCameraButtonVisible(canAddItems)
            
            if canAddItems {
                self?.view?.scrollToCameraThumbnail(animated: true)
            } else if let lastItem = items.last {
                self?.view?.selectItem(lastItem)
                self?.view?.scrollToItemThumbnail(lastItem, animated: true)
            }
            
            self?.interactor.items { items in
                self?.view?.setPhotoTitle("Фото \(items.count)")
            }
            
            self?.onItemsAdd?(items)
        }
    }
    
    private func removeItem(item: MediaPickerItem) {
        
        interactor.removeItem(item) { [weak self] adjacentItem, canAddItems in
            
            self?.view?.removeItem(item)
            self?.view?.setCameraButtonVisible(canAddItems)
            
            if let adjacentItem = adjacentItem {
                self?.view?.selectItem(adjacentItem)
            } else {
                self?.view?.setMode(.Camera)
                self?.view?.setPhotoTitleAlpha(0)
            }
            
            self?.onItemRemove?(item)
        }
    }
    
    private func showPhotoLibrary() {
        
        interactor.numberOfItemsAvailableForAdding { [weak self] maxItemsCount in
            
            self?.router.showPhotoLibrary(maxSelectedItemsCount: maxItemsCount) { module in
                
                module.onFinish = { photoLibraryItems in
                    
                    let mediaPickerItems = photoLibraryItems.map {
                        MediaPickerItem(
                            identifier: $0.identifier,
                            image: CachingImageSource(underlyingImageSource: $0.image)
                        )
                    }
                    
                    self?.addItems(mediaPickerItems, fromCamera: false)
                    self?.router.focusOnCurrentModule()
                }
            }
        }
    }
    
    private func showCroppingModule(forItem item: MediaPickerItem) {
        
        router.showCroppingModule(photo: item) { module in
            
            module.onDiscard = { [weak self] in
                self?.router.focusOnCurrentModule()
            }
            
            module.onConfirm = { [weak self] croppedImageSource in
                
                let croppedItem = MediaPickerItem(identifier: item.identifier, image: croppedImageSource)
                
                self?.interactor.updateItem(croppedItem) {
                    self?.view?.updateItem(croppedItem)
                    self?.onItemUpdate?(croppedItem)
                    self?.router.focusOnCurrentModule()
                }
            }
        }
    }
}
