import Foundation

final class PhotoLibraryV2Presenter: PhotoLibraryV2Module {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryV2Interactor
    private let router: PhotoLibraryV2Router
    private let overridenTheme: PaparazzoUITheme
    private let isMetalEnabled: Bool
    private let isNewFlowPrototype: Bool
    
    weak var mediaPickerModule: MediaPickerModule?
    
    weak var view: PhotoLibraryV2ViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.onViewDidLoad?()
                self?.setUpView()
            }
        }
    }
    
    // MARK: - Config
    private let shouldAllowFinishingWithNoPhotos: Bool
    
    // MARK: - State
    private var shouldScrollToTopOnFullReload = true
    private var continueButtonPlacement: MediaPickerContinueButtonPlacement?
    private var continueButtonTitle: String?
    
    // MARK: - Init
    
    init(
        interactor: PhotoLibraryV2Interactor,
        router: PhotoLibraryV2Router,
        overridenTheme: PaparazzoUITheme,
        isMetalEnabled: Bool,
        isNewFlowPrototype: Bool)
    {
        self.interactor = interactor
        self.router = router
        self.overridenTheme = overridenTheme
        self.isMetalEnabled = isMetalEnabled
        self.isNewFlowPrototype = isNewFlowPrototype
        self.shouldAllowFinishingWithNoPhotos = !interactor.selectedItems.isEmpty
        
        if isNewFlowPrototype {
            interactor.observeSelectedItemsChange { [weak self] in
                self?.adjustSelectedPhotosBar()
            }
        }
    }
    
    // MARK: - PhotoLibraryV2Module
    
    var onItemsAdd: (([MediaPickerItem], _ startIndex: Int) -> ())?
    var onItemUpdate: ((MediaPickerItem, _ index: Int?) -> ())?
    var onItemAutocorrect: ((MediaPickerItem, _ isAutocorrected: Bool, _ index: Int?) -> ())?
    var onItemMove: ((_ sourceIndex: Int, _ destinationIndex: Int) -> ())?
    var onItemRemove: ((MediaPickerItem, _ index: Int?) -> ())?
    var onCropFinish: (() -> ())?
    var onCropCancel: (() -> ())?
    var onContinueButtonTap: (() -> ())?
    var onViewDidLoad: (() -> ())?
    var onCancel: (() -> ())?
    var onFinish: (([MediaPickerItem]) -> ())?
    var onNewCameraShow: (() -> ())?
    
    func setContinueButtonTitle(_ title: String) {
        continueButtonTitle = title
        updateContinueButtonTitle()
    }
    
    func setContinueButtonEnabled(_ enabled: Bool) {
        mediaPickerModule?.setContinueButtonEnabled(enabled)
    }
    
    func setContinueButtonVisible(_ visible: Bool) {
        mediaPickerModule?.setContinueButtonVisible(visible)
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        mediaPickerModule?.setContinueButtonStyle(style)
        view?.setContinueButtonStyle(style)
    }
    
    func setContinueButtonPlacement(_ placement: MediaPickerContinueButtonPlacement) {
        continueButtonPlacement = placement
        view?.setContinueButtonPlacement(placement)
    }
    
    public func setCameraTitle(_ title: String) {
        mediaPickerModule?.setCameraTitle(title)
    }
    
    public func setCameraSubtitle(_ subtitle: String) {
        mediaPickerModule?.setCameraSubtitle(subtitle)
    }
    
    public func setCameraHint(data: CameraHintData) {
        mediaPickerModule?.setCameraHint(data: data)
    }
    
    public func setAccessDeniedTitle(_ title: String) {
        mediaPickerModule?.setAccessDeniedTitle(title)
    }
    
    public func setAccessDeniedMessage(_ message: String) {
        mediaPickerModule?.setAccessDeniedMessage(message)
    }
    
    public func setAccessDeniedButtonTitle(_ title: String) {
        mediaPickerModule?.setAccessDeniedButtonTitle(title)
    }
    
    func setCropMode(_ cropMode: MediaPickerCropMode) {
        mediaPickerModule?.setCropMode(cropMode)
    }
    
    func setThumbnailsAlwaysVisible(_ alwaysVisible: Bool) {
        mediaPickerModule?.setThumbnailsAlwaysVisible(alwaysVisible)
    }
    
    func removeItem(_ item: MediaPickerItem) {
        mediaPickerModule?.removeItem(item)
    }
    
    func focusOnModule() {
        router.focusOnCurrentModule()
    }
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
    func finish() {
        mediaPickerModule?.finish()
    }
    
    // MARK: - Private
    private func setUpView() {
        
        updateContinueButtonTitle()
        
        view?.setTitleVisible(false)
        
        view?.setPlaceholderState(.hidden)
        
        view?.setAccessDeniedTitle(localized("To pick photo from library"))
        view?.setAccessDeniedMessage(localized("Allow %@ to access your photo library", appName()))
        view?.setAccessDeniedButtonTitle(localized("Allow access to photo library"))
        view?.setDoneButtonTitle(localized("Done"))
        view?.setPlaceholderText(localized("Select at least one photo"))
        
        view?.setProgressVisible(true)
        
        view?.setContinueButtonVisible(!isNewFlowPrototype)
        
        if isNewFlowPrototype {
            view?.onViewWillAppear = { [weak self] in
                DispatchQueue.main.async {
                    self?.adjustSelectedPhotosBar()
                    self?.view?.reloadSelectedItems()
                }
            }
        }
        
        interactor.observeAuthorizationStatus { [weak self] accessGranted in
            self?.view?.setAccessDeniedViewVisible(!accessGranted)
            
            if !accessGranted {
                self?.view?.setProgressVisible(false)
            }
        }
        
        interactor.observeAlbums { [weak self] albums in
            guard let strongSelf = self else { return }
            
            // We're showing only non-empty albums
            let albums = albums.filter { $0.numberOfItems > 0 }
            
            self?.view?.setAlbums(albums.map(strongSelf.albumCellData))
            
            if let currentAlbum = strongSelf.interactor.currentAlbum, albums.contains(currentAlbum) {
                self?.adjustView(for: currentAlbum)  // title might have been changed
            } else if let album = albums.first {
                self?.selectAlbum(album)
            } else {
                self?.view?.setTitleVisible(false)
                self?.view?.setPlaceholderState(.visible(title: localized("No photos")))
                self?.view?.setProgressVisible(false)
            }
        }
        
        interactor.observeCurrentAlbumEvents { [weak self] event, selectionState in
            guard let strongSelf = self else { return }
            
            var needToShowPlaceholder: Bool
            
            switch event {
            case .fullReload(let items):
                needToShowPlaceholder = items.isEmpty
                self?.view?.setItems(
                    items.map(strongSelf.cellData),
                    scrollToTop: strongSelf.shouldScrollToTopOnFullReload,
                    completion: {
                        self?.shouldScrollToTopOnFullReload = false
                        self?.adjustViewForSelectionState(selectionState)
                        self?.view?.setProgressVisible(false)
                    }
                )
                
            case .incrementalChanges(let changes):
                needToShowPlaceholder = changes.itemsAfterChanges.isEmpty
                self?.view?.applyChanges(strongSelf.viewChanges(from: changes), completion: {
                    self?.adjustViewForSelectionState(selectionState)
                })
            }
            
            self?.view?.setPlaceholderState(
                needToShowPlaceholder ? .visible(title: localized("Album is empty")) : .hidden
            )
        }
        
        view?.onContinueButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            
            let selectedItems = strongSelf.interactor.selectedItems
            
            guard selectedItems.isEmpty == false else {
                strongSelf.onFinish?([])
                return
            }
            
            let mediaPickerItems = selectedItems.map {
                MediaPickerItem(
                    image: $0.image,
                    source: .photoLibrary
                )
            }
            
            let startIndex = 0
            
            self?.onItemsAdd?(
                mediaPickerItems,
                startIndex
            )
            
            guard !strongSelf.isNewFlowPrototype else {
                strongSelf.onFinish?(mediaPickerItems)
                return
            }
            
            let data = strongSelf.interactor.mediaPickerData.bySettingPhotoLibraryItems(selectedItems)
            
            self?.router.showMediaPicker(
                data: data,
                overridenTheme: strongSelf.overridenTheme,
                isMetalEnabled: strongSelf.isMetalEnabled,
                isNewFlowPrototype: strongSelf.isNewFlowPrototype,
                configure: { [weak self] module in
                    self?.configureMediaPicker(module)
                }
            )
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.onCancel?()
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        
        view?.onLastPhotoThumbnailTap = { [weak self] in
            self?.showMediaPickerInNewFlow()
        }
        
        view?.onTitleTap = { [weak self] in
            self?.view?.toggleAlbumsList()
        }
        
        view?.onDimViewTap = { [weak self] in
            self?.view?.hideAlbumsList()
        }
        
        interactor.observeDeviceOrientation { [weak self] orientation in
            self?.cameraViewData { [weak self] viewData in
                self?.view?.setCameraViewData(viewData)
            }
        }
    }
    
    private func showMediaPickerInNewFlow() {
        
        let data = interactor.mediaPickerData
            .bySettingPhotoLibraryItems(interactor.selectedItems)
            .bySelectingLastItem()
        
        router.showMediaPicker(
            data: data,
            overridenTheme: overridenTheme,
            isMetalEnabled: isMetalEnabled,
            isNewFlowPrototype: true,
            configure: { [weak self] module in
                self?.configureMediaPicker(module)
                module.onFinish = { _ in
                    self?.router.focusOnCurrentModule()
                }
            }
        )
    }
    
    private func updateContinueButtonTitle() {
        let title = interactor.selectedItems.isEmpty ? localized("Continue") : localized("Select")
        view?.setContinueButtonTitle(continueButtonTitle ?? title)
    }
    
    private func appName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    private func adjustViewForSelectionState(_ state: PhotoLibraryItemSelectionState) {
        view?.setDimsUnselectedItems(!state.canSelectMoreItems)
        view?.setCanSelectMoreItems(state.canSelectMoreItems)
        
        switch state.preSelectionAction {
        case .none:
            break
        case .deselectAll:
            view?.deselectAllItems()
        }
    }
    
    private func albumCellData(for album: PhotoLibraryAlbum) -> PhotoLibraryAlbumCellData {
        return PhotoLibraryAlbumCellData(
            identifier: album.identifier,
            title: album.title ?? localized("Unnamed album"),
            coverImage: album.coverImage,
            onSelect: { [weak self] in
                self?.selectAlbum(album)
                self?.view?.hideAlbumsList()
            }
        )
    }
    
    private func selectAlbum(_ album: PhotoLibraryAlbum) {
        shouldScrollToTopOnFullReload = true
        interactor.setCurrentAlbum(album)
        adjustView(for: album)
    }
    
    private func adjustView(for album: PhotoLibraryAlbum) {
        view?.setTitle(album.title ?? localized("Unnamed album"))
        view?.setTitleVisible(true)
        view?.selectAlbum(withId: album.identifier)
    }
    
    private func cellData(_ item: PhotoLibraryItem) -> PhotoLibraryItemCellData {
        
        let getSelectionIndex = { [weak self] in
            self?.interactor.selectedItems.index(of: item).flatMap { $0 + 1 }
        }
        
        var cellData = PhotoLibraryItemCellData(
            image: item.image,
            getSelectionIndex: isNewFlowPrototype ? getSelectionIndex : nil
        )

        cellData.selected = interactor.isSelected(item)
        
        cellData.onSelectionPrepare = { [weak self] in
            if let selectionState = self?.interactor.prepareSelection() {
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        cellData.onSelect = { [weak self] in
            if let selectionState = self?.interactor.selectItem(item) {
                self?.adjustViewForSelectionState(selectionState)
            }
            
            if self?.isNewFlowPrototype == false {
                self?.view?.setHeaderVisible(false)
            }
            
            self?.updateContinueButtonTitle()
        }
        
        cellData.onDeselect = { [weak self] in
            self?.handleItemDeselect(item)
        }
        
        return cellData
    }
    
    private func handleItemDeselect(_ item: PhotoLibraryItem) {
        
        let selectionState = interactor.deselectItem(item)
        
        adjustViewForSelectionState(selectionState)
        
        if isNewFlowPrototype {
            view?.reloadSelectedItems()
        } else {
            view?.setHeaderVisible(interactor.selectedItems.isEmpty)
        }
        
        updateContinueButtonTitle()
    }
    
    private func cameraViewData(completion: @escaping (_ viewData: PhotoLibraryCameraViewData?) -> ()) {
        interactor.getOutputParameters { [shouldAllowFinishingWithNoPhotos] parameters in
            let viewData = PhotoLibraryCameraViewData(
                parameters: parameters,
                onTap: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    if strongSelf.isNewFlowPrototype {
                        self?.onNewCameraShow?()
                        self?.router.showNewCamera(
                            selectedImagesStorage: strongSelf.interactor.selectedPhotosStorage,
                            mediaPickerData: strongSelf.interactor.mediaPickerData,
                            shouldAllowFinishingWithNoPhotos: shouldAllowFinishingWithNoPhotos,
                            configure: { [weak self] newCameraModule in
                                newCameraModule.configureMediaPicker = { mediaPickerModule in
                                    self?.configureMediaPicker(mediaPickerModule)
                                    mediaPickerModule.onFinish = { [weak newCameraModule] _ in
                                        newCameraModule?.focusOnModule()
                                    }
                                }
                                newCameraModule.onFinish = { module, result in
                                    switch result {
                                    case .finished:
                                        self?.view?.onContinueButtonTap?()
                                    case .cancelled:
                                        self?.router.focusOnCurrentModule()
                                    }
                                }
                            }
                        )
                    } else {
                        self?.router.showMediaPicker(
                            data: strongSelf.interactor.mediaPickerData.byDisablingLibrary(),
                            overridenTheme: strongSelf.overridenTheme,
                            isMetalEnabled: strongSelf.isMetalEnabled,
                            isNewFlowPrototype: strongSelf.isNewFlowPrototype,
                            configure: { [weak self] module in
                                self?.configureMediaPicker(module)
                            }
                        )
                    }
                }
            )
            
            completion(viewData)
        }
    }
    
    private func configureMediaPicker(_ module: MediaPickerModule) {
        
        mediaPickerModule = module
        
        if let continueButtonPlacement = continueButtonPlacement {
            module.setContinueButtonPlacement(continueButtonPlacement)
        }
        
        if let continueButtonTitle = continueButtonTitle {
            module.setContinueButtonTitle(continueButtonTitle)
        }
        
        module.onItemsAdd = onItemsAdd
        module.onItemUpdate = onItemUpdate
        module.onItemAutocorrect = onItemAutocorrect
        module.onItemMove = { [weak self] sourceIndex, destinationIndex in
            self?.interactor.moveSelectedItem(at: sourceIndex, to: destinationIndex)
            self?.onItemMove?(sourceIndex, destinationIndex)
        }
        module.onItemRemove = { [weak self] mediaPickerItem, index in
            if self?.view?.deselectItem(with: mediaPickerItem.image) == false {
                // Кейс, когда удаляется "виртуальная" фотка (серверная, которой нет в галерее)
                self?.handleItemDeselect(PhotoLibraryItem(image: mediaPickerItem.image))
            }
            self?.onItemRemove?(mediaPickerItem, index)
        }
        module.onCropFinish = onCropFinish
        module.onCropCancel = onCropCancel
        module.onContinueButtonTap = onContinueButtonTap
        module.onFinish = onFinish
        module.onCancel = { [weak module] in
            module?.dismissModule()
        }
    }
    
    private func viewChanges(from changes: PhotoLibraryChanges) -> PhotoLibraryViewChanges {
        return PhotoLibraryViewChanges(
            removedIndexes: changes.removedIndexes,
            insertedItems: changes.insertedItems.map { (index: $0, cellData: cellData($1)) },
            updatedItems: changes.updatedItems.map { (index: $0, cellData: cellData($1)) },
            movedIndexes: changes.movedIndexes
        )
    }
    
    func adjustSelectedPhotosBar() {
        let images = interactor.selectedItems
        
        view?.setSelectedPhotosBarState(images.isEmpty
            ? (shouldAllowFinishingWithNoPhotos ? .placeholder : .hidden)
            : .visible(SelectedPhotosBarData(
                lastPhoto: images.last?.image,
                penultimatePhoto: images.count > 1 ? images[images.count - 2].image : nil,
                countString: "\(images.count) фото"
            ))
        )
    }
}

extension MediaPickerData {
    func bySettingPhotoLibraryItems(_ items: [PhotoLibraryItem]) -> MediaPickerData {
        let mediaPickerItems = items.map {
            MediaPickerItem(
                image: $0.image,
                source: .photoLibrary
            )
        }
        return MediaPickerData(
            items: mediaPickerItems,
            autocorrectionFilters: autocorrectionFilters,
            selectedItem: mediaPickerItems.first ?? selectedItem,
            maxItemsCount: maxItemsCount,
            cropEnabled: cropEnabled,
            autocorrectEnabled: autocorrectEnabled,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            cropCanvasSize: cropCanvasSize,
            initialActiveCameraType: initialActiveCameraType,
            cameraEnabled: false,
            photoLibraryEnabled: false
        )
    }
    
    func bySelectingLastItem() -> MediaPickerData {
        return MediaPickerData(
            items: items,
            autocorrectionFilters: autocorrectionFilters,
            selectedItem: items.last,
            maxItemsCount: maxItemsCount,
            cropEnabled: cropEnabled,
            autocorrectEnabled: autocorrectEnabled,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            cropCanvasSize: cropCanvasSize,
            initialActiveCameraType: initialActiveCameraType,
            cameraEnabled: cameraEnabled,
            photoLibraryEnabled: photoLibraryEnabled
        )
    }
    
    func byDisablingLibrary() -> MediaPickerData {
        return MediaPickerData(
            items: items,
            autocorrectionFilters: autocorrectionFilters,
            selectedItem: selectedItem,
            maxItemsCount: maxItemsCount,
            cropEnabled: cropEnabled,
            autocorrectEnabled: autocorrectEnabled,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            cropCanvasSize: cropCanvasSize,
            initialActiveCameraType: initialActiveCameraType,
            cameraEnabled: cameraEnabled,
            photoLibraryEnabled: false
        )
    }
}
