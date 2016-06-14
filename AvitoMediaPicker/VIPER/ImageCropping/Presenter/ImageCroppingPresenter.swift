import Foundation

final class ImageCroppingPresenter: ImageCroppingModuleInput {

    private var interactor: ImageCroppingInteractor {
        didSet {
            setupInteractor()
        }
    }
    
    private let router: ImageCroppingRouter

    // MARK: - Init

    init(interactor: ImageCroppingInteractor, router: ImageCroppingRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Weak properties
    weak var view: ImageCroppingViewInput? {
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
