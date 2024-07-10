import Foundation

final class ScannerPresenter: ScannerModule {
    
    // MARK: - Dependencies
    
    private let interactor: ScannerInteractor
    private let router: ScannerRouter
    private let cameraModuleInput: CameraModuleInput
    
    // MARK: - Init
    
    init(interactor: ScannerInteractor, router: ScannerRouter, cameraModuleInput: CameraModuleInput) {
        self.interactor = interactor
        self.router = router
        self.cameraModuleInput = cameraModuleInput
    }
    
    weak var view: ScannerViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
            }
        }
    }
    
    // MARK: - ScannerModule

    var onFinish: (() -> ())?
    var onCancel: (() -> ())?
    
    public func setAccessDeniedTitle(_ title: String) {
        cameraModuleInput.setAccessDeniedTitle(title)
    }
    
    public func setAccessDeniedMessage(_ message: String) {
        cameraModuleInput.setAccessDeniedMessage(message)
    }
    
    public func setAccessDeniedButtonTitle(_ title: String) {
        cameraModuleInput.setAccessDeniedButtonTitle(title)
    }
    
    func focusOnModule() {
        router.focusOnCurrentModule()
    }
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ()) {
        cameraModuleInput.takePhoto(completion: completion)
    }
    
    func finish() {
        onFinish?()
    }
    
    func showInfoMessage(_ message: String, timeout: TimeInterval) {
        view?.showInfoMessage(message, timeout: timeout)
    }

    // MARK: - Private
    
    private func setUpView() {
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
        
        view?.onViewWillAppear = { [weak self] animated in
            self?.cameraModuleInput.setCameraOutputNeeded(true)
        }
        view?.onViewDidAppear = { [weak self] animated in
            self?.cameraModuleInput.mainModuleDidAppear(animated: animated)
        }
        
        view?.onViewDidDisappear = { [weak self] animated in
            self?.cameraModuleInput.setCameraOutputNeeded(false)
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.onCancel?()
        }
        
        cameraModuleInput.getOutputParameters { [weak self] parameters in
            if let parameters = parameters {
                self?.interactor.setCameraOutputParameters(parameters)
            }
        }
    }
    
}
