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
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
            }
        }
    }
    
    // MARK: - MediaPickerModule

    var onItemsAdd: ([MediaPickerItem] -> ())?
    var onItemUpdate: (MediaPickerItem -> ())?
    var onItemRemove: (MediaPickerItem -> ())?
    var onFinish: ([MediaPickerItem] -> ())?
    var onCancel: (() -> ())?
    
    func setItems(items: [MediaPickerItem], selectedItem: MediaPickerItem?) {
        addItems(items, fromCamera: false) { [weak self] in
            if let selectedItem = selectedItem {
                self?.view?.selectItem(selectedItem)
            }
        }
    }
    
    func focusOnModule() {
        router.focusOnCurrentModule()
    }
    
    func dismissModule() {
        router.dismissCurrentModule()
    }

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
        
        interactor.items { [weak self] items, canAddMoreItems in
            guard items.count > 0 else { return }
            
            self?.view?.addItems(items, animated: false)
            self?.view?.setCameraButtonVisible(canAddMoreItems)
            
            self?.interactor.selectedItem { selectedItem in
                if let selectedItem = selectedItem {
                    self?.selectItem(selectedItem)
                } else if canAddMoreItems {
                    self?.selectCamera()
                } else if let lastItem = items.last {
                    self?.selectItem(lastItem)
                }
            }
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
            self?.interactor.selectItem(item)
            self?.adjustViewForSelectedItem(item, animated: true)
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
            self?.interactor.items { items, _ in
                self?.onFinish?(items)
            }
        }
        
        view?.onCropButtonTap = { [weak self] in
            self?.interactor.selectedItem { item in
                if let item = item {
                    self?.showCroppingModule(forItem: item)
                }
            }
        }
        
        view?.onRemoveButtonTap = { [weak self] in
            self?.removeSelectedItem()
        }
    }
    
    private func adjustViewForSelectedItem(item: MediaPickerItem, animated: Bool) {
        adjustPhotoTitleForItem(item)
        
        view?.setMode(.PhotoPreview(item))
        view?.scrollToItemThumbnail(item, animated: animated)
    }
    
    private func adjustPhotoTitleForItem(item: MediaPickerItem) {
        interactor.indexOfItem(item) { [weak self] index in
            if let index = index {
                self?.setTitleForPhotoWithIndex(index)
                self?.view?.setPhotoTitleAlpha(1)
            }
        }
    }
    
    private func setTitleForPhotoWithIndex(index: Int) {
        view?.setPhotoTitle("Фото \(index + 1)")
    }
    
    private func addItems(items: [MediaPickerItem], fromCamera: Bool, completion: (() -> ())? = nil) {
        interactor.addItems(items) { [weak self] canAddItems in
            self?.handleItemsAdded(items, fromCamera: fromCamera, canAddMoreItems: canAddItems, completion: completion)
        }
    }
    
    private func selectItem(item: MediaPickerItem) {
        view?.selectItem(item)
        adjustViewForSelectedItem(item, animated: false)
    }
    
    private func selectCamera() {
        view?.setMode(.Camera)
        view?.scrollToCameraThumbnail(animated: false)
    }
    
    private func handleItemsAdded(items: [MediaPickerItem], fromCamera: Bool, canAddMoreItems: Bool, completion: (() -> ())? = nil) {
        
        guard items.count > 0 else { completion?(); return }
        
        view?.addItems(items, animated: fromCamera)
        view?.setCameraButtonVisible(canAddMoreItems)
        
        if canAddMoreItems {
            view?.setMode(.Camera)
            view?.scrollToCameraThumbnail(animated: true)
        } else if let lastItem = items.last {
            view?.selectItem(lastItem)
            view?.scrollToItemThumbnail(lastItem, animated: true)
        }
        
        interactor.items { [weak self] items, _ in
            self?.setTitleForPhotoWithIndex(items.count - 1)
        }
        
        onItemsAdd?(items)
        
        completion?()
    }
    
    private func removeSelectedItem() {
        
        interactor.selectedItem { [weak self] item in
            guard let item = item else { return }
            
            self?.interactor.removeItem(item) { adjacentItem, canAddItems in
                
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
    }
    
    private func showPhotoLibrary() {
        
        interactor.numberOfItemsAvailableForAdding { [weak self] maxItemsCount in
            self?.interactor.photoLibraryItems { photoLibraryItems in
             
                self?.router.showPhotoLibrary(selectedItems: [], maxSelectedItemsCount: maxItemsCount) { module in
                    
                    module.onFinish = { photoLibraryItems in
                        
                        self?.interactor.addPhotoLibraryItems(photoLibraryItems) { mediaPickerItems, canAddItems in
                            self?.handleItemsAdded(mediaPickerItems, fromCamera: false, canAddMoreItems: canAddItems)
                        }
                        
                        self?.router.focusOnCurrentModule()
                    }
                }
            }
        }
    }
    
    private func showCroppingModule(forItem item: MediaPickerItem) {
        
        router.showCroppingModule(forImage: item.image) { module in
            
            module.onDiscard = { [weak self] in
                self?.router.focusOnCurrentModule()
            }
            
            module.onConfirm = { [weak self] croppedImageSource in
                
                let croppedItem = MediaPickerItem(
                    identifier: item.identifier,
                    image: croppedImageSource,
                    source: item.source
                )
                
                self?.interactor.updateItem(croppedItem) {
                    self?.view?.updateItem(croppedItem)
                    self?.onItemUpdate?(croppedItem)
                    self?.router.focusOnCurrentModule()
                }
            }
        }
    }
}
