import Foundation

final class PhotoLibraryV2Presenter: PhotoLibraryV2Module {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryV2Interactor
    private let router: PhotoLibraryV2Router
    private let overridenTheme: PaparazzoUITheme
    private let isMetalEnabled: Bool
    
    weak var mediaPickerModule: MediaPickerModule?
    
    weak var view: PhotoLibraryV2ViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
            }
        }
    }
    
    // MARK: - State
    var shouldScrollToTopOnFullReload = true
    
    // MARK: - Init
    
    init(
        interactor: PhotoLibraryV2Interactor,
        router: PhotoLibraryV2Router,
        overridenTheme: PaparazzoUITheme,
        isMetalEnabled: Bool)
    {
        self.interactor = interactor
        self.router = router
        self.overridenTheme = overridenTheme
        self.isMetalEnabled = isMetalEnabled
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
    var onCancel: (() -> ())?
    var onFinish: (([MediaPickerItem]) -> ())?
    
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
    private var continueButtonTitle: String?
    
    private func setUpView() {
        
        updateContinueButtonTitle()
        
        view?.setTitleVisible(false)
        
        view?.setPlaceholderState(.hidden)
        
        view?.setAccessDeniedTitle(localized("To pick photo from library"))
        view?.setAccessDeniedMessage(localized("Allow %@ to access your photo library", appName()))
        view?.setAccessDeniedButtonTitle(localized("Allow access to photo library"))
        
        view?.setProgressVisible(true)
        
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
            if let strongSelf = self {
                let selectedItems = strongSelf.interactor.selectedItems
                guard selectedItems.isEmpty == false else {
                    self?.onFinish?([])
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
                
                let data = strongSelf.interactor.mediaPickerData.bySettingPhotoLibraryItems(
                    selectedItems
                )
                
                self?.router.showMediaPicker(
                    data: data,
                    overridenTheme: strongSelf.overridenTheme,
                    isMetalEnabled: strongSelf.isMetalEnabled,
                    configure: { [weak self] module in
                        weak var weakModule = module
                        self?.mediaPickerModule = module
                        module.onItemsAdd = self?.onItemsAdd
                        module.onItemUpdate = self?.onItemUpdate
                        module.onItemAutocorrect = self?.onItemAutocorrect
                        module.onItemMove = self?.onItemMove
                        module.onItemRemove = { mediaPickerItem, index in
                            self?.view?.deselectItem(with: mediaPickerItem.image)
                            self?.onItemRemove?(mediaPickerItem, index)
                        }
                        module.onCropFinish = self?.onCropFinish
                        module.onCropCancel = self?.onCropCancel
                        module.onContinueButtonTap = self?.onContinueButtonTap
                        module.onCancel = {
                            weakModule?.dismissModule()
                        }
                        
                        module.onFinish = self?.onFinish
                })
            }
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.onCancel?()
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
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
        
        var cellData = PhotoLibraryItemCellData(image: item.image)

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
            
            self?.view?.setHeaderVisible(false)
            self?.updateContinueButtonTitle()
        }
        
        cellData.onDeselect = { [weak self] in
            if let selectionState = self?.interactor.deselectItem(item) {
                self?.adjustViewForSelectionState(selectionState)
            }
            let hasNoItems = self?.interactor.selectedItems.isEmpty == true
            self?.view?.setHeaderVisible(hasNoItems)
            self?.updateContinueButtonTitle()
        }
        
        return cellData
    }
    
    private func cameraViewData(completion: @escaping (_ viewData: PhotoLibraryCameraViewData?) -> ()) {
        interactor.getOutputParameters { parameters in
            let viewData = PhotoLibraryCameraViewData(
                parameters: parameters,
                onTap: { [weak self] in
                    guard let strongSelf = self else { return }
                    self?.router.showMediaPicker(
                        data: strongSelf.interactor.mediaPickerData.byDisablingLibrary(),
                        overridenTheme: strongSelf.overridenTheme,
                        isMetalEnabled: strongSelf.isMetalEnabled,
                        configure: { [weak self] module in
                            weak var weakModule = module
                            self?.mediaPickerModule = module
                            module.onItemsAdd = self?.onItemsAdd
                            module.onItemUpdate = self?.onItemUpdate
                            module.onItemAutocorrect = self?.onItemAutocorrect
                            module.onItemMove = self?.onItemMove
                            module.onItemRemove = self?.onItemRemove
                            module.onCropFinish = self?.onCropFinish
                            module.onCropCancel = self?.onCropCancel
                            module.onContinueButtonTap = self?.onContinueButtonTap
                            module.onCancel = {
                                weakModule?.dismissModule()
                            }
                            
                            module.onFinish = self?.onFinish
                    })
                }
            )
            
            completion(viewData)
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
