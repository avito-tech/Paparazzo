import Foundation
import ImageSource
import UIKit

final class PhotoLibraryV3Presenter: PhotoLibraryV3Module {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryV3Interactor
    private let router: PhotoLibraryV3Router
    private let overridenTheme: PaparazzoUITheme
    private var cameraType: MediaPickerCameraType
    private let onCameraV3InitializationMeasurementStart: (() -> ())?
    private let onCameraV3InitializationMeasurementStop: (() -> ())?
    private let onCameraV3DrawingMeasurementStart: (() -> ())?
    private let onCameraV3DrawingMeasurementStop: (() -> ())?
    
    weak var mediaPickerModule: MediaPickerModule?
    
    weak var view: PhotoLibraryV3ViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.onViewDidLoad?()
                self?.setUpView()
            }
        }
    }
    
    // MARK: - Config
    private let isPaparazzoImageUpdaingFixEnabled: Bool
    private let shouldAllowFinishingWithNoPhotos: Bool
    
    // MARK: - State
    private var shouldScrollToTopOnFullReload = true
    private var isObservingLimitedAccessAlert = false
    private var continueButtonPlacement: MediaPickerContinueButtonPlacement?
    private var continueButtonTitle: String?
    
    // MARK: - Init
    
    init(
        interactor: PhotoLibraryV3Interactor,
        router: PhotoLibraryV3Router,
        overridenTheme: PaparazzoUITheme,
        cameraType: MediaPickerCameraType,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) {
        self.interactor = interactor
        self.router = router
        self.overridenTheme = overridenTheme
        self.shouldAllowFinishingWithNoPhotos = !interactor.selectedItems.isEmpty
        self.cameraType = cameraType
        self.isPaparazzoImageUpdaingFixEnabled = isPaparazzoImageUpdaingFixEnabled
        self.onCameraV3InitializationMeasurementStart = onCameraV3InitializationMeasurementStart
        self.onCameraV3InitializationMeasurementStop = onCameraV3InitializationMeasurementStop
        self.onCameraV3DrawingMeasurementStart = onCameraV3DrawingMeasurementStart
        self.onCameraV3DrawingMeasurementStop = onCameraV3DrawingMeasurementStop
    }
    
    // MARK: - PhotoLibraryV3Module
    
    var onItemsAdd: (([MediaPickerItem], _ startIndex: Int) -> ())?
    var onItemUpdate: ((MediaPickerItem, _ index: Int?) -> ())?
    var onItemAutocorrect: ((MediaPickerItem, _ isAutocorrected: Bool, _ index: Int?) -> ())?
    var onItemMove: ((_ sourceIndex: Int, _ destinationIndex: Int) -> ())?
    var onItemRemove: ((MediaPickerItem, _ index: Int?) -> ())?
    var onItemAutoEnhance: ((MediaPickerItem, _ isAllowedEnhace: Bool) -> ())?
    var onItemSelectSetAutoEnhanceStatusIfNeeded: ((MediaPickerItem) -> ())?
    var onCropFinish: (() -> ())?
    var onCropCancel: (() -> ())?
    var onContinueButtonTap: (() -> ())?
    var onViewDidLoad: (() -> ())?
    var onCancel: (() -> ())?
    var onFinish: (([MediaPickerItem]) -> ())?
    var onCameraV3Show: (() -> ())?
    var onCropButtonTap: (() -> ())?
    var onLastPhotoThumbnailTap: (() -> ())?
    var onRotationAngleChange: (() -> ())?
    var onRotateButtonTap: (() -> ())?
    var onGridButtonTap: ((Bool) -> ())?
    var onAspectRatioButtonTap: ((String) -> ())?
    var onItemStateDidChange: ((MediaPickerImageState) -> ())?
    
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
    
    public func setAutoEnhanceImage(_ image: MediaPickerItem?, prevImage: MediaPickerItem, isEnhanced: Bool) {
        mediaPickerModule?.setAutoEnhanceImage(image, prevImage: prevImage, isEnhanced: isEnhanced)
    }
    
    func setImagePerceptionBadge(_ badge: ImagePerceptionBadgeViewData) {
        mediaPickerModule?.setImagePerceptionBadge(badge)
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
        
        view?.setContinueButtonVisible(false)
        
        view?.onViewWillAppear = { [weak self] in
            dispatch_to_main_queue {
                guard let self else { return }
                
                self.addObserveSelectedItemsChange()
                self.adjustSelectedPhotosBar()
                
                let selectionState = self.interactor.prepareSelection()
                self.adjustViewForSelectionState(selectionState)
            }
        }
        
        interactor.observeAuthorizationStatus { [weak self] accessGranted in
            dispatch_to_main_queue {
                guard let self else { return }
                
                self.view?.setAccessDeniedViewVisible(!accessGranted)
                if !accessGranted {
                    self.view?.setProgressVisible(false)
                }
            }
        }
        
        if #available(iOS 14, *) {
            view?.onViewDidAppear = { [weak self] in
                guard let self, !isObservingLimitedAccessAlert else { return }
                isObservingLimitedAccessAlert = true
                interactor.observeLimitedAccess { [weak self] in
                    self?.router.showLimitedAccessAlert()
                }
            }
        }
        
        interactor.observeAlbums { [weak self] albums in
            dispatch_to_main_queue {
                guard let self else { return }
                
                // We're showing only non-empty albums
                let albums = albums.filter { $0.numberOfItems > 0 }
                
                self.view?.setAlbums(albums.map(self.albumCellData))
                
                if let currentAlbum = self.interactor.currentAlbum, albums.contains(currentAlbum) {
                    self.adjustView(for: currentAlbum)  // title might have been changed
                } else if let album = albums.first {
                    self.selectAlbum(album)
                } else {
                    self.view?.setTitleVisible(false)
                    self.view?.setPlaceholderState(.visible(title: localized("No photos")))
                    self.view?.setProgressVisible(false)
                }
            }
        }
        
        interactor.observeCurrentAlbumEvents { [weak self] event, selectionState in
            dispatch_to_main_queue {
                guard let self else { return }
                
                var needToShowPlaceholder: Bool
                
                switch event {
                case .fullReload(let items):
                    needToShowPlaceholder = items.isEmpty
                    self.view?.setItems(
                        items.map(self.cellData),
                        scrollToTop: self.shouldScrollToTopOnFullReload,
                        completion: { [weak self] in
                            dispatch_to_main_queue {
                                guard let self else { return }
                                self.shouldScrollToTopOnFullReload = false
                                self.adjustViewForSelectionState(selectionState)
                                self.view?.setProgressVisible(false)
                            }
                        }
                    )
                    
                case .incrementalChanges(let changes):
                    needToShowPlaceholder = changes.itemsAfterChanges.isEmpty
                    self.view?.applyChanges(self.viewChanges(from: changes), completion: { [weak self] in
                        dispatch_to_main_queue {
                            guard let self else { return }
                            self.adjustViewForSelectionState(selectionState)
                        }
                    })
                }
                
                self.view?.setPlaceholderState(
                    needToShowPlaceholder ? .visible(title: localized("Album is empty")) : .hidden
                )
            }
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
            
            strongSelf.interactor.setCameraOutputNeeded(false)
            strongSelf.onFinish?(selectedItems)
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.interactor.setCameraOutputNeeded(false)
            self?.onCancel?()
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
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
    
    private func adjustViewForSelectionState(_ state: PhotoLibraryV3ItemSelectionState) {
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
    
    private func cellData(_ item: PhotoLibraryV3Item) -> PhotoLibraryV3ItemCellData {
        
        let mediaPickerItem = MediaPickerItem(item)
        
        let getSelectionIndex = { [weak self] in
            self?.interactor.selectedItems.firstIndex(of: mediaPickerItem).flatMap { $0 + 1 }
        }
        
        var cellData = PhotoLibraryV3ItemCellData(
            image: item.image,
            getSelectionIndex: getSelectionIndex
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
        view?.reloadSelectedItems()
        
        updateContinueButtonTitle()
    }
    
    private func cameraViewData(completion: @escaping (_ viewData: PhotoLibraryV3CameraViewData?) -> ()) {
        interactor.getOutputParameters { parameters in
            let viewData = PhotoLibraryV3CameraViewData(
                parameters: parameters,
                onTap: { [weak self] in
                    self?.handlePhotoLibraryCameraTap()
                }
            )
            
            completion(viewData)
        }
    }
    
    private func handlePhotoLibraryCameraTap() {
        switch cameraType {
        case .cameraV3:
            openCameraV3()
        case .medicalBookCamera:
            openMedicalBookCamera()
        }
    }
    
    private func openCameraV3() {
        onCameraV3Show?()
        router.showCameraV3(
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
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
            },
            onInitializationMeasurementStart: onCameraV3InitializationMeasurementStart,
            onInitializationMeasurementStop: onCameraV3InitializationMeasurementStop,
            onDrawingMeasurementStart: onCameraV3DrawingMeasurementStart,
            onDrawingMeasurementStop: onCameraV3DrawingMeasurementStop
        )
    }
    
    private func openMedicalBookCamera() {
        router.showMedicalBookCamera(
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            selectedImagesStorage: interactor.selectedPhotosStorage,
            mediaPickerData: interactor.mediaPickerData,
            configure: { [weak self] medicalBookModule in
                medicalBookModule.configureMediaPicker = { [weak self, weak medicalBookModule] pickerModule in
                    self?.configureMediaPicker(pickerModule)
                    pickerModule.onFinish = { _ in
                        medicalBookModule?.focusOnCurrentModule()
                    }
                }
                
                medicalBookModule.onFinish = { module, result in
                    switch result {
                    case .finished:
                        self?.view?.onContinueButtonTap?()
                    case .cancelled:
                        self?.router.focusOnCurrentModule()
                    }
                }
                medicalBookModule.onLastPhotoThumbnailTap = { [weak self] in
                    self?.onLastPhotoThumbnailTap?()
                }
            }
        )
    }
    
    private func openPicker() {
        router.showMediaPicker(
            data: interactor.mediaPickerData.byDisablingLibrary(),
            overridenTheme: overridenTheme,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isNewFlowPrototype: true,
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
    
    private func viewChanges(from changes: PhotoLibraryV3Changes) -> PhotoLibraryV3ViewChanges {
        return PhotoLibraryV3ViewChanges(
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
                countString: localized("%d photo", images.count)
            ))
        )
    }

    private func addObserveSelectedItemsChange() {
        interactor.observeSelectedItemsChange { [weak self] in
            self?.adjustSelectedPhotosBar()
        }
    }
}
