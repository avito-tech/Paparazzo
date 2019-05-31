import ImageSource

final class CameraPresenter: CameraModuleInput {
    
    private let interactor: CameraInteractor
    
    weak var view: CameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Init
    
    init(interactor: CameraInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - CameraModuleInput
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ()) {
        interactor.getOutputParameters(completion: completion)
    }
    
    func setCameraOutputNeeded(_ isCameraOutputNeeded: Bool) {
        interactor.setCameraOutputNeeded(isCameraOutputNeeded)
    }
    
    func isFlashAvailable(completion: @escaping (Bool) -> ()) {
        interactor.isFlashAvailable(completion: completion)
    }
    
    func isFlashEnabled(completion: @escaping (Bool) -> ()) {
        interactor.isFlashEnabled(completion: completion)
    }
    
    func setFlashEnabled(_ enabled: Bool, completion: ((_ success: Bool) -> ())?) {
        interactor.setFlashEnabled(enabled, completion: completion)
    }
    
    func canToggleCamera(completion: @escaping (Bool) -> ()) {
        interactor.canToggleCamera(completion: completion)
    }
    
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ()) {
        interactor.toggleCamera { [weak self] newOutputOrientation in
            self?.view?.setOutputOrientation(newOutputOrientation)
            completion(newOutputOrientation)
        }
    }
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ()) {
        interactor.takePhoto(completion: completion)
    }
    
    func setPreviewImagesSizeForNewPhotos(_ size: CGSize) {
        interactor.setPreviewImagesSizeForNewPhotos(size)
    }
    
    func mainModuleDidAppear(animated: Bool) {
        view?.mainModuleDidAppear(animated: animated)
    }
    
    func setAccessDeniedTitle(_ title: String) {
        view?.setAccessDeniedTitle(title)
    }
    
    func setAccessDeniedMessage(_ message: String) {
        view?.setAccessDeniedMessage(message)
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        view?.setAccessDeniedButtonTitle(title)
    }
    
    func setTitle(_ title: String) {
        view?.setTitle(title)
    }
    
    func setSubtitle(_ subtitle: String) {
        view?.setSubtitle(subtitle)
    }
    
    func setCameraHintVisible(_ visible: Bool) {
        view?.setCameraHintVisible(visible)
    }
    func setCameraHint(text: String) {
        view?.setCameraHint(text: text)
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setAccessDeniedTitle(localized("To take photo"))
        view?.setAccessDeniedMessage(localized("Allow %@ to use your camera", appName()))
        view?.setAccessDeniedButtonTitle(localized("Allow access to camera"))
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        
        interactor.getOutputParameters { [weak self] parameters in
            if let parameters = parameters {
                self?.view?.setOutputParameters(parameters)
            } else {
                self?.view?.setAccessDeniedViewVisible(true)
            }
        }
        
        view?.onFocusTap = { [weak self] focusPoint, touchPoint in
            if self?.interactor.focusCameraOnPoint(focusPoint) == true {
                self?.view?.displayFocus(onPoint: touchPoint)
            }
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
    }
    
    private func appName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
}
