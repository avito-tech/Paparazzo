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

    var onItemsAdd: (([MediaPickerItem]) -> ())?
    var onItemUpdate: ((MediaPickerItem) -> ())?
    var onItemRemove: ((MediaPickerItem) -> ())?
    var onFinish: (([MediaPickerItem]) -> ())?
    var onCancel: (() -> ())?
    
    func setContinueButtonTitle(_ title: String) {
        continueButtonTitle = title
        view?.setContinueButtonTitle(title)
    }
    
    func setContinueButtonEnabled(_ enabled: Bool) {
        view?.setContinueButtonEnabled(enabled)
    }
    
    func setItems(_ items: [MediaPickerItem], selectedItem: MediaPickerItem?) {
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
    
    private var continueButtonTitle: String?
    
    private func setUpView() {
        
        view?.setContinueButtonTitle(continueButtonTitle ?? "Далее")
        view?.setPhotoTitle("Фото 1")
        
        view?.setCameraControlsEnabled(false)
        
        cameraModuleInput.getOutputParameters { [weak self] parameters in
            if let parameters = parameters {
                self?.view?.setCameraOutputParameters(parameters)
                self?.view?.setCameraControlsEnabled(true)
            }
        }
        
        cameraModuleInput.isFlashAvailable { [weak self] flashAvailable in
            self?.view?.setFlashButtonVisible(flashAvailable)
        }
        
        cameraModuleInput.isFlashEnabled { [weak self] isFlashEnabled in
            self?.view?.setFlashButtonOn(isFlashEnabled)
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
            
            self?.view?.setCameraButtonVisible(canAddMoreItems)
            self?.view?.addItems(items, animated: false) {
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
        }
        
        view?.onPhotoLibraryButtonTap = { [weak self] in
            self?.showPhotoLibrary()
        }
        
        view?.onShutterButtonTap = { [weak self] in
            
            // Если фоткать со вспышкой, это занимает много времени, и если несколько раз подряд быстро тапнуть на кнопку,
            // он будет потом еще долго фоткать :) Поэтому временно блокируем кнопку.
            // Кроме того, если быстро нажать "Далее", то фотка не попадет в module result, поэтому "Далее" также блокируем
            self?.view?.setShutterButtonEnabled(false)
            self?.view?.setPhotoLibraryButtonEnabled(false) // AI-3207
            self?.view?.setContinueButtonEnabled(false)
            self?.view?.animateFlash()
            
            self?.cameraModuleInput.takePhoto { photo in
                
                if let photo = photo {
                    self?.addItems([photo], fromCamera: true)
                }
                
                self?.view?.setShutterButtonEnabled(true)
                self?.view?.setPhotoLibraryButtonEnabled(true)
                self?.view?.setContinueButtonEnabled(true)
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
        
        view?.onItemMove = { [weak self] (sourceIndex, destinationIndex) in
            self?.interactor.moveItem(from: sourceIndex, to: destinationIndex)
            self?.interactor.selectedItem { item in
                if let item = item {
                    self?.adjustViewForSelectedItem(item, animated: true)
                }
            }
            self?.view?.moveItem(from: sourceIndex, to: destinationIndex)
        }
        
        view?.onCameraThumbnailTap = { [weak self] in
            self?.interactor.selectItem(nil)
            self?.view?.setMode(.camera)
            self?.view?.scrollToCameraThumbnail(animated: true)
        }
        
        view?.onCameraToggleButtonTap = { [weak self] in
            self?.cameraModuleInput.toggleCamera { newOutputOrientation in
                self?.view?.setCameraOutputOrientation(newOutputOrientation)
            }
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
            self?.cameraModuleInput.setFlashEnabled(false, completion: nil)
            self?.onCancel?()
        }
        
        view?.onContinueButtonTap = { [weak self] in
            self?.cameraModuleInput.setFlashEnabled(false, completion: nil)
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
        
        view?.onPreviewSizeDetermined = { [weak self] previewSize in
            self?.cameraModuleInput.setPreviewImagesSizeForNewPhotos(previewSize)
        }
        
        view?.onViewDidAppear = { [weak self] animated in
            self?.cameraModuleInput.mainModuleDidAppear(animated: animated)
        }
    }
    
    private func adjustViewForSelectedItem(_ item: MediaPickerItem, animated: Bool) {
        adjustPhotoTitleForItem(item)
        
        view?.setMode(.photoPreview(item))
        view?.scrollToItemThumbnail(item, animated: animated)
    }
    
    private func adjustPhotoTitleForItem(_ item: MediaPickerItem) {
        interactor.indexOfItem(item) { [weak self] index in
            if let index = index {
                self?.setTitleForPhotoWithIndex(index)
                self?.view?.setPhotoTitleAlpha(1)
                
                item.image.imageSize { size in
                    let isPortrait = size.flatMap { $0.height > $0.width } ?? true
                    self?.view?.setPhotoTitleStyle(isPortrait ? .light : .dark)
                }
            }
        }
    }
    
    private func setTitleForPhotoWithIndex(_ index: Int) {
        view?.setPhotoTitle("Фото \(index + 1)")
    }
    
    private func addItems(_ items: [MediaPickerItem], fromCamera: Bool, completion: (() -> ())? = nil) {
        interactor.addItems(items) { [weak self] addedItems, canAddItems in
            self?.handleItemsAdded(addedItems, fromCamera: fromCamera, canAddMoreItems: canAddItems, completion: completion)
        }
    }
    
    private func selectItem(_ item: MediaPickerItem) {
        view?.selectItem(item)
        adjustViewForSelectedItem(item, animated: false)
    }
    
    private func selectCamera() {
        interactor.selectItem(nil)
        view?.setMode(.camera)
        view?.scrollToCameraThumbnail(animated: false)
    }
    
    private func handleItemsAdded(_ items: [MediaPickerItem], fromCamera: Bool, canAddMoreItems: Bool, completion: (() -> ())? = nil) {
        
        guard items.count > 0 else { completion?(); return }
        
        view?.addItems(items, animated: fromCamera) { [view] in
            view?.setCameraButtonVisible(canAddMoreItems)
            
            if canAddMoreItems {
                view?.setMode(.camera)
                view?.scrollToCameraThumbnail(animated: true)
            } else if let lastItem = items.last {
                view?.selectItem(lastItem)
                view?.scrollToItemThumbnail(lastItem, animated: true)
            }
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
                    self?.view?.setMode(.camera)
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
                    
                    module.onFinish = { result in
                        self?.router.focusOnCurrentModule()
                        
                        switch result {
                        case .selectedItems(let photoLibraryItems):
                            self?.interactor.addPhotoLibraryItems(photoLibraryItems) { addedItems, canAddItems in
                                self?.handleItemsAdded(addedItems, fromCamera: false, canAddMoreItems: canAddItems)
                            }
                        case .cancelled:
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func showCroppingModule(forItem item: MediaPickerItem) {
        
        interactor.cropCanvasSize { [weak self] cropCanvasSize in
            
            self?.router.showCroppingModule(forImage: item.image, canvasSize: cropCanvasSize) { module in
                
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
                        self?.adjustPhotoTitleForItem(croppedItem)
                        self?.onItemUpdate?(croppedItem)
                        self?.router.focusOnCurrentModule()
                    }
                }
            }
        }
    }
}
