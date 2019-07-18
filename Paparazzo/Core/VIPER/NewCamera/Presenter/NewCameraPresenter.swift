final class NewCameraPresenter:
    NewCameraModule
{
    // MARK: - Private properties
    private let interactor: NewCameraInteractor
    private let router: NewCameraRouter
    
    // MARK: - Init
    init(
        interactor: NewCameraInteractor,
        router: NewCameraRouter)
    {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Weak properties
    weak var view: NewCameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - NewCameraModule
    var onFinish: ((NewCameraModule, NewCameraModuleResult) -> ())?
    
    // MARK: - Private
    private func setUpView() {
        view?.onCloseButtonTap = { [weak self] in
            self?.router.dismissCurrentModule()
        }
    }
}
