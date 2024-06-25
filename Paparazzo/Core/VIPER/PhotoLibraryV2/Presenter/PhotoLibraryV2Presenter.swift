import Foundation
import UIKit

final class PhotoLibraryV2Presenter: PhotoLibraryV2Module {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryV2Interactor
    private let router: PhotoLibraryV2Router
    private let overridenTheme: PaparazzoUITheme
    private let isNewFlowPrototype: Bool
    private let isUsingCameraV3: Bool
    private let isPaparazzoCellDisablingFixEnabled: Bool
    
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
        isNewFlowPrototype: Bool,
        isUsingCameraV3: Bool,
        isPaparazzoCellDisablingFixEnabled: Bool
    ) {
        self.interactor = interactor
        self.router = router
        self.overridenTheme = overridenTheme
        self.isNewFlowPrototype = isNewFlowPrototype
        self.shouldAllowFinishingWithNoPhotos = !interactor.selectedItems.isEmpty
        self.isUsingCameraV3 = isUsingCameraV3
        self.isPaparazzoCellDisablingFixEnabled = isPaparazzoCellDisablingFixEnabled
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
    var onCameraV3Show: (() -> ())?
    var onCropButtonTap: (() -> ())?
    var onLastPhotoThumbnailTap: (() -> ())?
    var onRotationAngleChange: (() -> ())?
    var onRotateButtonTap: (() -> ())?
    var onGridButtonTap: ((Bool) -> ())?
    var onAspectRatioButtonTap: ((String) -> ())?
    
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
                    self?.addObserveSelectedItemsChange()
                    self?.adjustSelectedPhotosBar()

                    if self?.isPaparazzoCellDisablingFixEnabled ?? false, let selectionState = self?.interactor.prepareSelection() {
                        self?.adjustViewForSelectionState(selectionState)
                    } else {
                        self?.view?.reloadSelectedItems()
                    }
                }
            }
        }
        
        interactor.observeAuthorizationStatus { [weak self] accessGranted in
            self?.view?.setAccessDeniedViewVisible(!accessGranted)
            
            if !accessGranted {
                self?.view?.setProgressVisible(false)
            }
        }
        
        if #available(iOS 14, *) {
            interactor.onLimitedAccess = { [weak self] in
                DispatchQueue.main.async {
                    self?.router.showLimitedAccessAlert()
                } 
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
                    guard let self = self else { return }
                    self.adjustViewForSelectionState(selectionState)
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
                strongSelf.interactor.setCameraOutputNeeded(false)
                strongSelf.onFinish?([])
                return
            }
            
            let startIndex = 0
            
            self?.onItemsAdd?(
                selectedItems,
                startIndex
            )
            
            guard !strongSelf.isNewFlowPrototype else {
                strongSelf.interactor.setCameraOutputNeeded(false)
                strongSelf.onFinish?(selectedItems)
                return
            }
            
            let data = strongSelf.interactor.mediaPickerData.bySettingMediaPickerItems(selectedItems)
            
            self?.router.showMediaPicker(
                data: data,
                overridenTheme: strongSelf.overridenTheme,
                isNewFlowPrototype: strongSelf.isNewFlowPrototype,
                configure: { [weak self] module in
                    self?.configureMediaPicker(module)
                }
            )
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.interactor.setCameraOutputNeeded(false)
            self?.onCancel?()
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        
        view?.onLastPhotoThumbnailTap = { [weak self] in
            self?.showMediaPickerInNewFlow()
            self?.onLastPhotoThumbnailTap?()
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
            .bySettingMediaPickerItems(interactor.selectedItems)
            .bySelectingLastItem()
        
        router.showMediaPicker(
            data: data,
            overridenTheme: overridenTheme,
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
        
        let mediaPickerItem = MediaPickerItem(item)
        
        let getSelectionIndex = { [weak self] in
            self?.interactor.selectedItems.firstIndex(of: mediaPickerItem).flatMap { $0 + 1 }
        }
        
        var cellData = PhotoLibraryItemCellData(
            image: item.image,
            getSelectionIndex: isNewFlowPrototype ? getSelectionIndex : nil
        )

        cellData.selected = interactor.isSelected(mediaPickerItem)
        
        cellData.onSelectionPrepare = { [weak self] in
            if let selectionState = self?.interactor.prepareSelection() {
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        cellData.onSelect = { [weak self] in
            if let selectionState = self?.interactor.selectItem(mediaPickerItem) {
                self?.adjustViewForSelectionState(selectionState)
            }
            
            if self?.isNewFlowPrototype == false {
                self?.view?.setHeaderVisible(false)
            }
            
            self?.updateContinueButtonTitle()
        }
        
        cellData.onDeselect = { [weak self] in
            self?.handleItemDeselect(mediaPickerItem)
        }
        
        return cellData
    }
    
    private func handleItemDeselect(_ item: MediaPickerItem) {
        
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
        interactor.getOutputParameters { parameters in
            let viewData = PhotoLibraryCameraViewData(
                parameters: parameters,
                onTap: { [weak self] in
                    self?.handlePhotoLibraryCameraTap()
                }
            )
            
            completion(viewData)
        }
    }
    
    private func handlePhotoLibraryCameraTap() {
        if isUsingCameraV3 {
            openCameraV3()
        } else if isNewFlowPrototype {
            openNewCamera()
        } else {
            openPicker()
        }
    }
    
    private func openNewCamera() {
        onNewCameraShow?()
        router.showNewCamera(
            selectedImagesStorage: interactor.selectedPhotosStorage,
            mediaPickerData: interactor.mediaPickerData,
            shouldAllowFinishingWithNoPhotos: shouldAllowFinishingWithNoPhotos,
            configure: { [weak self] newCameraModule in
                newCameraModule.configureMediaPicker = { [weak newCameraModule] mediaPickerModule in
                    self?.configureMediaPicker(mediaPickerModule)
                    mediaPickerModule.onFinish = { _ in
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
                newCameraModule.onLastPhotoThumbnailTap = { [weak self] in
                    self?.onLastPhotoThumbnailTap?()
                }
            }
        )
    }
    
    private func openCameraV3() {
        onCameraV3Show?()
        router.showCameraV3(
            selectedImagesStorage: interactor.selectedPhotosStorage,
            mediaPickerData: interactor.mediaPickerData,
            configure: { [weak self] cameraV3Module in
                cameraV3Module.configureMediaPicker = { [weak self, weak cameraV3Module] pickerModule in
                    self?.configureMediaPicker(pickerModule)
                    pickerModule.onFinish = { _ in
                        cameraV3Module?.focusOnCurrentModule()
                    }
                }
                
                cameraV3Module.onFinish = { module, result in
                    switch result {
                    case .finished:
                        self?.view?.onContinueButtonTap?()
                    case .cancelled:
                        self?.router.focusOnCurrentModule()
                    }
                }
                cameraV3Module.onLastPhotoThumbnailTap = { [weak self] in
                    self?.onLastPhotoThumbnailTap?()
                }
            }
        )
    }
    
    private func openPicker() {
        router.showMediaPicker(
            data: interactor.mediaPickerData.byDisablingLibrary(),
            overridenTheme: overridenTheme,
            isNewFlowPrototype: isNewFlowPrototype,
            configure: { [weak self] module in
                self?.configureMediaPicker(module)
            }
        )
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
        module.onItemUpdate = { [weak self] item, index in
            if let index = index {
                self?.interactor.replaceSelectedItem(at: index, with: item)
            }
            self?.onItemUpdate?(item, index)
        }
        module.onItemAutocorrect = { [weak self] item, isAutocorrected, index in
            if let index = index {
                self?.interactor.replaceSelectedItem(at: index, with: item)
            }
            self?.onItemAutocorrect?(item, isAutocorrected, index)
        }
        module.onItemMove = { [weak self] sourceIndex, destinationIndex in
            self?.interactor.moveSelectedItem(at: sourceIndex, to: destinationIndex)
            self?.onItemMove?(sourceIndex, destinationIndex)
        }
        module.onItemRemove = { [weak self] mediaPickerItem, index in
            if self?.view?.deselectItem(with: mediaPickerItem.image) == false {
                // Кейс, когда удаляется "виртуальная" фотка (серверная, которой нет в галерее)
                self?.handleItemDeselect(mediaPickerItem)
            }
            if let originalItem = mediaPickerItem.originalItem {
                // Кейс, когда удаляется фотка, на которую наложен фильтр
                // (вьюха не знает про связь измененной фотки с оригинальной)
                self?.view?.deselectItem(with: originalItem.image)
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
        module.onCropButtonTap = onCropButtonTap
        module.onRotationAngleChange = onRotationAngleChange
        module.onRotateButtonTap = onRotateButtonTap
        module.onGridButtonTap = onGridButtonTap
        module.onAspectRatioButtonTap = onAspectRatioButtonTap
    }
    
    private func viewChanges(from changes: PhotoLibraryChanges) -> PhotoLibraryViewChanges {
        return PhotoLibraryViewChanges(
            removedIndexes: changes.removedIndexes,
            insertedItems: changes.insertedItems.map { (index: $0, cellData: cellData($1)) },
            updatedItems: changes.updatedItems.map { (index: $0, cellData: cellData($1)) },
            movedIndexes: changes.movedIndexes
        )
    }
    
    private func adjustSelectedPhotosBar() {
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

    private func addObserveSelectedItemsChange() {
        interactor.observeSelectedItemsChange { [weak self] in
            self?.adjustSelectedPhotosBar()
        }
    }
}

extension MediaPickerData {
    func bySettingMediaPickerItems(_ mediaPickerItems: [MediaPickerItem]) -> MediaPickerData {
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
