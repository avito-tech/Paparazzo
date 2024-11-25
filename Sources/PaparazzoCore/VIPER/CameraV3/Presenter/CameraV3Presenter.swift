import ImageSource
import UIKit

final class CameraV3Presenter: CameraV3Module {
    // MARK: - Private properties
    private let interactor: CameraV3Interactor
    private let router: CameraV3Router
    private let volumeService: VolumeService
    private let isPresentingPhotosFromCameraFixEnabled: Bool
    private let onDrawingMeasurementStart: (() -> ())?
    private let onDrawingMeasurementStop: (() -> ())?
    
    // MARK: - Init
    init(
        interactor: CameraV3Interactor,
        volumeService: VolumeService,
        router: CameraV3Router,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        onDrawingMeasurementStart: (() -> ())?,
        onDrawingMeasurementStop: (() -> ())?
    ) {
        self.interactor = interactor
        self.volumeService = volumeService
        self.router = router
        self.isPresentingPhotosFromCameraFixEnabled = isPresentingPhotosFromCameraFixEnabled
        self.onDrawingMeasurementStart = onDrawingMeasurementStart
        self.onDrawingMeasurementStop = onDrawingMeasurementStop
    }
    
    var onLastPhotoThumbnailTap: (() -> ())?
    var configureMediaPicker: ((MediaPickerModule) -> ())?
    var onFinish: ((CameraV3Module, CameraV3ModuleResult) -> ())?
    
    // MARK: - Weak properties
    weak var view: CameraV3ViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Private
    private func setUpView() {
        weak var weakSelf = self
        
        view?.setFlashButtonVisible(interactor.isFlashAvailable)
        view?.setFlashButtonOn(interactor.isFlashEnabled)
        
        view?.setAccessDeniedTitle(localized("To take photo"))
        view?.setAccessDeniedMessage(localized("Allow %@ to use your camera", appName()))
        view?.setAccessDeniedButtonTitle(localized("Allow access to camera"))
        
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
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        
        view?.onShutterButtonTap = {
            weakSelf?.view?.setShutterButtonEnabled(false, false)
            weakSelf?.takePhoto()
        }
        
        view?.onLastPhotoThumbnailTap = { [interactor, router, isPresentingPhotosFromCameraFixEnabled] in
            router.showMediaPicker(
                isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
                data: interactor.mediaPickerDataWithSelectedLastItem,
                overridenTheme: nil,
                configure: { module in
                    weakSelf?.configureMediaPicker?(module)
                }
            )

            weakSelf?.onLastPhotoThumbnailTap?()
        }
        
        view?.onFocusTap = { focusPoint, touchPoint in
            if weakSelf?.interactor.focusCameraOnPoint(focusPoint) == true {
                weakSelf?.view?.showFocus(on: touchPoint)
            }
        }
        
        view?.onDrawingMeasurementStop = { [weak self] in
            self?.onDrawingMeasurementStop?()
        }
        
        view?.onViewWillAppear = { _ in
            weakSelf?.volumeService.subscribe()
            weakSelf?.adjustHintText()
            weakSelf?.adjustPhotoLibraryItems(animated: false)
            weakSelf?.adjustShutterButtonAvailability(animated: false)
            weakSelf?.onDrawingMeasurementStart?()
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
    
    private func appName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
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
        let text = interactor.items.isEmpty ? "Разместите объект внутри рамки — эту область покажем в\u{00A0}поиске" : ""
        view?.setHintText(text)
    }
    
    private func takePhoto() {
        guard interactor.canAddNewItems else { return }
        
        view?.animateShot()
        interactor.takePhoto { [weak self] in
            guard let photo = $0 else {
                self?.adjustShutterButtonAvailability()
                return
            }
            self?.interactor.addItem(MediaPickerItem(image: photo.image, source: .camera))
            self?.adjustShutterButtonAvailability()
            self?.adjustHintText()
        }
    }
    
    private func finish(with result: CameraV3ModuleResult) {
        onFinish?(self, result)
    }
    
    // MARK: - CameraV3Module
    func focusOnCurrentModule() {
        router.focusOnCurrentModule()
    }
}
