import Foundation

final class PhotoLibraryPresenter: PhotoLibraryModuleInput {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryInteractor
    private let router: PhotoLibraryRouter
    
    weak var moduleOutput: PhotoLibraryModuleOutput?
    
    weak var view: PhotoLibraryViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Init
    
    init(interactor: PhotoLibraryInteractor, router: PhotoLibraryRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
    }
    
    private func setupInteractor() {
        
    }
}
