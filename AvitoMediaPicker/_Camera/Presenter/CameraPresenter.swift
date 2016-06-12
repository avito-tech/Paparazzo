import Foundation

final class CameraPresenter: CameraModuleInput {
    // MARK: - Init
    private var interactor: CameraInteractor {
        didSet {
            setupInteractor()
        }
    }
    
    private let router: CameraRouter
    
    init(interactor: CameraInteractor, router: CameraRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Weak properties
    weak var view: CameraViewInput? {
        didSet {
            setupView()
        }
    }
    
    // MARK: - CameraModuleInput
    
    // MARK: - Private
    private func setupView() {
        
    }
    
    private func setupInteractor() {
        
    }
}
