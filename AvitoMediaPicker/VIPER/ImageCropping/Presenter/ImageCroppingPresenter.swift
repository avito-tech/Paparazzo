import Foundation

final class ImageCroppingPresenter: ImageCroppingModuleInput {

    // MARK: - Dependencies
    
    private var interactor: ImageCroppingInteractor
    private let router: ImageCroppingRouter
    
    weak var moduleOutput: ImageCroppingModuleOutput?
    
    weak var view: ImageCroppingViewInput? {
        didSet {
            setUpView()
        }
    }

    // MARK: - Init

    init(interactor: ImageCroppingInteractor, router: ImageCroppingRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
    }
    
    private func setupInteractor() {
        
    }
}
