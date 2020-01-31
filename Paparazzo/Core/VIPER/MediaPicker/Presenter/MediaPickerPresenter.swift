final class MediaPickerPresenter: MediaPickerModule {
    
    // MARK: - Config
    private let isNewFlowPrototype: Bool
    
    // MARK: - Dependencies
    private let interactor: MediaPickerInteractor
    private let router: MediaPickerRouter
    private let cameraModuleInput: CameraModuleInput
    
    // MARK: - Init
    
    init(
        isNewFlowPrototype: Bool,
        interactor: MediaPickerInteractor,
        router: MediaPickerRouter,
        cameraModuleInput: CameraModuleInput)
    {
        self.isNewFlowPrototype = isNewFlowPrototype
        self.interactor = interactor
        self.router = router
        self.cameraModuleInput = cameraModuleInput
    }
    
    weak var view: MediaPickerViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
                DispatchQueue.main.async {
                    self?.onViewDidLoad?()
                }
            }
        }
    }
    
    // MARK: - MediaPickerModule

    var onItemsAdd: (([MediaPickerItem], _ startIndex: Int) -> ())?
    var onItemUpdate: ((MediaPickerItem, _ index: Int?) -> ())?
    var onItemAutocorrect: ((MediaPickerItem, _ isAutocorrected: Bool, _ index: Int?) -> ())?
    var onItemMove: ((_ sourceIndex: Int, _ destinationIndex: Int) -> ())?
    var onItemRemove: ((MediaPickerItem, _ index: Int?) -> ())?
    var onCropFinish: (() -> ())?
    var onCropCancel: (() -> ())?
    var onContinueButtonTap: (() -> ())?
    var onViewDidLoad: (() -> ())?
    var onFinish: (([MediaPickerItem]) -> ())?
    var onCancel: (() -> ())?
    
    func setContinueButtonTitle(_ title: String) {
        continueButtonTitle = title
        view?.setContinueButtonTitle(title)
    }
    
    func setContinueButtonEnabled(_ enabled: Bool) {
        view?.setContinueButtonEnabled(enabled)
    }
    
    func setContinueButtonVisible(_ visible: Bool) {
        view?.setContinueButtonVisible(visible)
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        view?.setContinueButtonStyle(style)
    }
    
    func setContinueButtonPlacement(_ placement: MediaPickerContinueButtonPlacement) {
        view?.setContinueButtonPlacement(placement)
    }
    
    public func setCameraTitle(_ title: String) {
        cameraModuleInput.setTitle(title)
    }
    
    public func setCameraSubtitle(_ subtitle: String) {
        cameraModuleInput.setSubtitle(subtitle)
    }
    
    public func setCameraHint(data: CameraHintData) {
        cameraModuleInput.setCameraHint(text: data.title)
        cameraHintDelay = data.delay
    }
    
    public func setAccessDeniedTitle(_ title: String) {
        cameraModuleInput.setAccessDeniedTitle(title)
    }
    
    public func setAccessDeniedMessage(_ message: String) {
        cameraModuleInput.setAccessDeniedMessage(message)
    }
    
    public func setAccessDeniedButtonTitle(_ title: String) {
        cameraModuleInput.setAccessDeniedButtonTitle(title)
    }
    
    func setItems(_ items: [MediaPickerItem], selectedItem: MediaPickerItem?) {
        addItems(items, fromCamera: false) { [weak self] in
            if let selectedItem = selectedItem {
                self?.view?.selectItem(selectedItem)
            }
        }
    }
    
    func setCropMode(_ cropMode: MediaPickerCropMode) {
        interactor.setCropMode(cropMode)
    }
    
    func setThumbnailsAlwaysVisible(_ alwaysVisible: Bool) {
        thumbnailsAlwaysVisible = alwaysVisible
    }
    
    func removeItem(_ item: MediaPickerItem) {
        
        let itemWasSelected = (item == interactor.selectedItem)
        let index = interactor.indexOfItem(item)
        let adjacentItem = interactor.removeItem(item)
        let itemToSelectAfterRemoval = itemWasSelected ? adjacentItem : interactor.selectedItem
        
        view?.removeItem(item)
        
        let canShowCamera = interactor.canAddItems() && interactor.cameraEnabled
        
        view?.setCameraButtonVisible(canShowCamera)
        
        if let itemToSelectAfterRemoval = itemToSelectAfterRemoval {
            view?.selectItem(itemToSelectAfterRemoval)
        } else if canShowCamera {
            view?.selectCamera()
            view?.setPhotoTitleAlpha(0)
        } else if !isNewFlowPrototype {
            onCancel?()
        }
        
        onItemRemove?(item, index)
        
        if isNewFlowPrototype && itemToSelectAfterRemoval == nil {
            onFinish?([])
        }
    }
    
    func focusOnModule() {
        router.focusOnCurrentModule()
    }
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
    func finish() {
        cameraModuleInput.setFlashEnabled(false, completion: nil)
        onFinish?(interactor.items)
    }

    // MARK: - Private
    
    private var continueButtonTitle: String?
    private var cameraHintDelay: TimeInterval?
    private var thumbnailsAlwaysVisible: Bool = false {
        didSet {
            updateThumbnailsVisibility()
        }
    }
    
    private func setUpView() {
        
        view?.setContinueButtonTitle(continueButtonTitle ?? localized("Continue"))
        view?.setPhotoTitle(localized("Photo %d", 1))
        updateThumbnailsVisibility()
        
        view?.setCameraControlsEnabled(false)
        
        view?.setPhotoLibraryButtonVisible(interactor.photoLibraryEnabled)
        view?.setCameraButtonVisible(interactor.cameraEnabled)
        
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
        
        let items = interactor.items
        
        if items.count > 0 {
        
            view?.setCameraButtonVisible(interactor.canAddItems() && interactor.cameraEnabled)
            
            view?.addItems(items, animated: false) { [weak self] in
                let selectedItem = self?.interactor.selectedItem
                if let selectedItem = selectedItem {
                    self?.selectItem(selectedItem)
                } else if self?.interactor.canAddItems() == true && self?.interactor.cameraEnabled == true {
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
            // Кроме того, если быстро нажать "Далее", то фотка не попадет в module result, поэтому "Далее" также блокируем
            self?.view?.setShutterButtonEnabled(false)
            self?.view?.setPhotoLibraryButtonEnabled(false) // AI-3207
            self?.view?.setContinueButtonEnabled(false)
            self?.view?.animateFlash()
            
            self?.cameraModuleInput.takePhoto { photo in
                
                let enableShutterButton = {
                    self?.view?.setShutterButtonEnabled(true)
                    self?.view?.setPhotoLibraryButtonEnabled(true)
                    self?.view?.setContinueButtonEnabled(true)
                }
                
                if let photo = photo {
                    self?.addItems([photo], fromCamera: true, completion: enableShutterButton)
                } else {
                    enableShutterButton()
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
            self?.updateAutocorrectionStatusForItem(item)
            self?.adjustViewForSelectedItem(item, animated: true, scrollToSelected: true)
        }
        
        view?.onItemMove = { [weak self] (sourceIndex, destinationIndex) in
            self?.interactor.moveItem(from: sourceIndex, to: destinationIndex)
            self?.onItemMove?(sourceIndex, destinationIndex)
            if let item = self?.interactor.selectedItem {
                self?.updateAutocorrectionStatusForItem(item)
                self?.adjustViewForSelectedItem(item, animated: true, scrollToSelected: false)
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
            if let onContinueButtonTap = self?.onContinueButtonTap {
                onContinueButtonTap()
            } else {
                self?.finish()
            }
        }
        
        view?.onCropButtonTap = { [weak self] in
            if let item = self?.interactor.selectedItem {
                self?.showCroppingModule(forItem: item)
            }
        }
        
        view?.onAutocorrectButtonTap = { [weak self] in
            if let originalItem = self?.interactor.selectedItem?.originalItem {
                self?.view?.showInfoMessage(localized("AUTOCORRECTION OFF"), timeout: 1.0)
                self?.updateItem(originalItem, afterAutocorrect: true)
            } else {
                self?.view?.showInfoMessage(localized("AUTOCORRECTION ON"), timeout: 1.0)
                self?.view?.setAutocorrectionStatus(.corrected)
                self?.interactor.autocorrectItem(
                    onResult: { [weak self] updatedItem in
                        if let updatedItem = updatedItem {
                            self?.updateItem(updatedItem, afterAutocorrect: true)
                        }
                    }, onError: { [weak self] errorMessage in
                        if let errorMessage = errorMessage {
                            self?.view?.showInfoMessage(errorMessage, timeout: 1.0)
                        }
                        self?.view?.setAutocorrectionStatus(.original)
                    }
                )
            }
        }
        
        view?.onRemoveButtonTap = { [weak self] in
            self?.removeSelectedItem()
        }
        
        view?.onPreviewSizeDetermined = { [weak self] previewSize in
            self?.cameraModuleInput.setPreviewImagesSizeForNewPhotos(previewSize)
        }
        
        view?.onViewWillAppear = { [weak self] animated in
            self?.cameraModuleInput.setCameraOutputNeeded(true)
        }
        view?.onViewDidAppear = { [weak self] animated in
            self?.cameraModuleInput.mainModuleDidAppear(animated: animated)
            if let delay = self?.cameraHintDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self?.cameraModuleInput.setCameraHintVisible(false)
                }
            }
        }
        
        view?.onViewDidDisappear = { [weak self] animated in
            self?.cameraModuleInput.setCameraOutputNeeded(false)
        }
    }
    
    private func updateItem(_ updatedItem: MediaPickerItem, afterAutocorrect: Bool = false) {
        interactor.updateItem(updatedItem)
        view?.updateItem(updatedItem)
        adjustPhotoTitleForItem(updatedItem)
        let index = interactor.indexOfItem(updatedItem)
        updateAutocorrectionStatusForItem(updatedItem)
        
        if afterAutocorrect {
            onItemAutocorrect?(updatedItem, updatedItem.originalItem != nil, index)
        } else {
            onItemUpdate?(updatedItem, index)
        }
    }
    
    private func adjustViewForSelectedItem(_ item: MediaPickerItem, animated: Bool, scrollToSelected: Bool) {
        adjustPhotoTitleForItem(item)
        
        view?.setMode(.photoPreview(item))
        if scrollToSelected {
            view?.scrollToItemThumbnail(item, animated: animated)
        }
    }
    
    private func updateAutocorrectionStatusForItem(_ item: MediaPickerItem) {
        if item.originalItem == nil {
            view?.setAutocorrectionStatus(.original)
        } else {
            view?.setAutocorrectionStatus(.corrected)
        }
    }
    
    private func adjustPhotoTitleForItem(_ item: MediaPickerItem) {
        if let index = interactor.indexOfItem(item) {
            setTitleForPhotoWithIndex(index)
            view?.setPhotoTitleAlpha(1)
            
            item.image.imageSize { [weak self] size in
                let isPortrait = size.flatMap { $0.height > $0.width } ?? true
                self?.view?.setPreferredPhotoTitleStyle(isPortrait ? .light : .dark)
            }
        }
    }
    
    private func setTitleForPhotoWithIndex(_ index: Int) {
        view?.setPhotoTitle(localized("Photo %d", index + 1))
    }
    
    private func addItems(_ items: [MediaPickerItem], fromCamera: Bool, completion: (() -> ())? = nil) {
        let (addedItems, startIndex) = interactor.addItems(items)
        handleItemsAdded(
            addedItems,
            fromCamera: fromCamera,
            canAddMoreItems: interactor.canAddItems(),
            startIndex: startIndex,
            completion: completion
        )
    }
    
    private func selectItem(_ item: MediaPickerItem) {
        view?.selectItem(item)
        updateAutocorrectionStatusForItem(item)
        adjustViewForSelectedItem(item, animated: false, scrollToSelected: true)
    }
    
    private func updateThumbnailsVisibility() {
        view?.setShowPreview(interactor.maxItemsCount != 1 || thumbnailsAlwaysVisible)
    }
    
    private func selectCamera() {
        interactor.selectItem(nil)
        view?.setMode(.camera)
        view?.scrollToCameraThumbnail(animated: false)
    }
    
    private func handleItemsAdded(
        _ items: [MediaPickerItem],
        fromCamera: Bool,
        canAddMoreItems: Bool,
        startIndex: Int,
        completion: (() -> ())? = nil)
    {
        guard items.count > 0 else { completion?(); return }
        
        view?.addItems(items, animated: fromCamera) { [weak self, view] in
            
            guard let strongSelf = self else {
                completion?()
                return
            }
            
            view?.setCameraButtonVisible(canAddMoreItems && strongSelf.interactor.cameraEnabled)
            
            if fromCamera && canAddMoreItems {
                view?.setMode(.camera)
                view?.scrollToCameraThumbnail(animated: true)
            } else if let lastItem = items.last {
                view?.selectItem(lastItem)
                view?.scrollToItemThumbnail(lastItem, animated: true)
            }
            
            completion?()
            strongSelf.onItemsAdd?(items, startIndex)
        }
        
        setTitleForPhotoWithIndex(interactor.items.count - 1)
    }
    
    private func removeSelectedItem() {
        if let item = interactor.selectedItem {
            removeItem(item)
        }
    }
    
    private func showPhotoLibrary() {
        
        let maxItemsCount = interactor.numberOfItemsAvailableForAdding()
        
        let data = PhotoLibraryData(
            selectedItems: [],
            maxSelectedItemsCount: maxItemsCount
        )
        
        router.showPhotoLibrary(data: data) { [weak self] module in
            
            guard let strongSelf = self else { return }
            
            module.onFinish = { result in
                self?.router.focusOnCurrentModule()
                
                switch result {
                case .selectedItems(let photoLibraryItems):
                    let (addedItems, startIndex) = strongSelf.interactor.addPhotoLibraryItems(photoLibraryItems)
                    self?.handleItemsAdded(
                        addedItems,
                        fromCamera: false,
                        canAddMoreItems: strongSelf.interactor.canAddItems(),
                        startIndex: startIndex
                    )
                case .cancelled:
                    break
                }
            }
        }
    }
    
    private func showCroppingModule(forItem item: MediaPickerItem) {
        
        let cropCanvasSize = interactor.cropCanvasSize
        
        router.showCroppingModule(forImage: item.image, canvasSize: cropCanvasSize) { [weak self] module in
            
            module.onDiscard = { [weak self] in
                
                self?.onCropCancel?()
                self?.router.focusOnCurrentModule()
            }
            
            module.onConfirm = { [weak self] croppedImageSource in
                
                self?.onCropFinish?()
                let croppedItem = MediaPickerItem(
                    image: croppedImageSource,
                    source: item.source
                )
                
                self?.interactor.updateItem(croppedItem)
                self?.view?.updateItem(croppedItem)
                self?.adjustPhotoTitleForItem(croppedItem)
                if let index = self?.interactor.indexOfItem(croppedItem) {
                    self?.onItemUpdate?(croppedItem, index)
                    self?.router.focusOnCurrentModule()
                }
            }
        }
    }
}
