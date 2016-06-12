import Foundation

final class CroppingPresenter: CroppingModuleInput {
    // MARK: - Init
    private var interactor: CroppingInteractor {
        didSet {
            setupInteractor()
        }
    }
    
    private let router: CroppingRouter
    
    init(interactor: CroppingInteractor, router: CroppingRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Weak properties
    weak var view: CroppingViewInput? {
        didSet {
            setupView()
        }
    }
    
    // MARK: - CroppingModuleInput
    
    // MARK: - Private
    private func setupView() {
        
    }
    
    private func setupInteractor() {
        
    }
}
