import Foundation

final class PhotoLibraryPresenter: PhotoLibraryModuleInput {
    // MARK: - Init
    private var interactor: PhotoLibraryInteractor {
        didSet {
            setupInteractor()
        }
    }
    
    private let router: PhotoLibraryRouter
    
    init(interactor: PhotoLibraryInteractor, router: PhotoLibraryRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Weak properties
    weak var view: PhotoLibraryViewInput? {
        didSet {
            setupView()
        }
    }
    
    // MARK: - PhotoLibraryModuleInput
    
    // MARK: - Private
    private func setupView() {
        
    }
    
    private func setupInteractor() {
        
    }
}
