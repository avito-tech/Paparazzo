import ImageSource
import UIKit

final class MedicalBookCameraPresenter: MedicalBookCameraModule {
    // MARK: - Private properties
    private let isPhotoFetchLimitEnabled: Bool
    private let interactor: MedicalBookCameraInteractor
    private let router: MedicalBookCameraRouter
    private let volumeService: VolumeService
    
    // MARK: - Init
    init(
        isPhotoFetchLimitEnabled: Bool,
        interactor: MedicalBookCameraInteractor,
        router: MedicalBookCameraRouter,
        volumeService: VolumeService
    )
    {
        self.isPhotoFetchLimitEnabled = isPhotoFetchLimitEnabled
        self.interactor = interactor
        self.router = router
        self.volumeService = volumeService
    }
    
    var onLastPhotoThumbnailTap: (() -> ())?
    var configureMediaPicker: ((MediaPickerModule) -> ())?
    var onFinish: ((MedicalBookCameraModule, MedicalBookCameraModuleResult) -> ())?
    
    // MARK: - Weak properties
    weak var view: MedicalBookCameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Private
    private func setUpView() {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
        weak var weakSelf = self
        
        view?.setDoneButtonTitle(localized(Spec.doneButtonTitle))
        view?.setFlashButtonVisible(interactor.isFlashAvailable)
        view?.setFlashButtonOn(interactor.isFlashEnabled)
        
        view?.setAccessDeniedTitle(localized(Spec.deniedTitle))
        view?.setAccessDeniedMessage(localized(Spec.deniedMessage, appName))
        view?.setAccessDeniedButtonTitle(localized(Spec.deniedButtonTitle))
        
        view?.onCloseButtonTap = {
            guard let self = weakSelf else { return }
            weakSelf?.onFinish?(self, .cancelled)
        }
        
        view?.onToggleCameraButtonTap = {
            weakSelf?.interactor.toggleCamera()
        }
        
        view?.onFlashToggle = {
            guard let self = weakSelf, !self.interactor.setFlashEnabled($0) else { return }
            self.view?.setFlashButtonOn(!$0)
        }
        
        view?.onDoneButtonTap = {
            guard let self = weakSelf else { return }
            weakSelf?.onFinish?(self, .finished)
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        
        view?.onShutterButtonTap = {
            weakSelf?.view?.setShutterButtonEnabled(false, false)
            weakSelf?.takePhoto()
        }
        
        view?.onLastPhotoThumbnailTap = { [interactor, router, isPhotoFetchLimitEnabled] in
            router.showMediaPicker(
                isPhotoFetchLimitEnabled: isPhotoFetchLimitEnabled,
                data: interactor.mediaPickerDataWithSelectedLastItem,
                overridenTheme: nil,
                configure: { module in
                    weakSelf?.configureMediaPicker?(module)
                }
            )

            weakSelf?.onLastPhotoThumbnailTap?()
        }
        
        view?.onViewWillAppear = { _ in
            weakSelf?.volumeService.subscribe()
            weakSelf?.adjustHintText()
            weakSelf?.adjustDoneButtonVisibility()
            weakSelf?.adjustPhotoLibraryItems(animated: false)
            weakSelf?.adjustShutterButtonAvailability(animated: false)
        }
        
        view?.onViewDidDisappear = { _ in
            weakSelf?.volumeService.unsubscribe()
        }
        
        interactor.observeLatestLibraryPhoto { _ in
            weakSelf?.adjustPhotoLibraryItems()
        }
        
        interactor.observeCameraAuthorizationStatus {
            weakSelf?.view?.setAccessDeniedViewVisible(!$0)
        }
                
        volumeService.volumeButtonTapped = {
            weakSelf?.takePhoto()
        }
    }
    
    private func adjustShutterButtonAvailability(animated: Bool = true) {
        view?.setShutterButtonEnabled(interactor.canAddNewItems, animated)
    }
    
    private func adjustPhotoLibraryItems(animated: Bool = true) {
        if interactor.items.isEmpty {
            view?.setSelectedData(nil, animated: animated)
            view?.setSelectedDataEnabled(false)
            return
        }
        
        let itemsCount = interactor.items.count
        let total = interactor.maxItemsCount
        
        let lastElements = interactor.items.suffix(2)
        guard let topItem = lastElements.last?.image else {
            return
        }
        
        let behindItem = lastElements.count > 1 ? lastElements.first?.image : nil

        view?.setSelectedDataEnabled(true)
        view?.setSelectedData(
            .init(
                text: "\(itemsCount) из \(total)",
                topItem: topItem,
                behindItem: behindItem
            ),
            animated: animated
        )
    }
    
    private func adjustHintText() {
        let availableHintText = interactor.hintText ?? localized(Spec.hintText)
        let actualHintText = interactor.items.isEmpty ? availableHintText : ""
        view?.setHintText(actualHintText)
    }
    
    private func adjustDoneButtonVisibility() {
        view?.setDoneButtonVisible(!interactor.items.isEmpty)
    }
    
    private func takePhoto() {
        guard interactor.canAddNewItems else { return }
        
        view?.animateShot()
        interactor.takePhoto { [weak self] photo in
            guard let photo else {
                self?.adjustShutterButtonAvailability()
                return
            }
            
            self?.interactor.addItem(MediaPickerItem(image: photo.image, source: .camera))
            self?.adjustShutterButtonAvailability()
            self?.adjustHintText()
            self?.adjustDoneButtonVisibility()
        }
    }
    
    private func finish(with result: MedicalBookCameraModuleResult) {
        onFinish?(self, result)
    }
    
    // MARK: - MedicalBookCameraModule
    func focusOnCurrentModule() {
        router.focusOnCurrentModule()
    }
}

// MARK: - Spec
private enum Spec {
    static let doneButtonTitle = "Done"
    static let deniedTitle = "To take photo"
    static let deniedMessage = "Allow %@ to use your camera"
    static let deniedButtonTitle = "Allow access to camera"
    static let hintText = "Place the medical record in a frame"
}
