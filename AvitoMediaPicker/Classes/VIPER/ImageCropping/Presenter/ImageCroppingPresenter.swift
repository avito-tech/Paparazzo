import Foundation

final class ImageCroppingPresenter: ImageCroppingModule {

    // MARK: - Dependencies
    
    private var interactor: ImageCroppingInteractor
    private let router: ImageCroppingRouter
    
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
    
    // MARK: - ImageCroppingModule
    
    var onDiscard: (() -> ())?
    var onConfirm: (() -> ())?
    
    func setImage(image: ImageSource) {
        view?.setImage(image)
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.onDiscardButtonTap = { [weak self] in
            self?.onDiscard?()
        }
        
        view?.onConfirmButtonTap = { [weak self] in
            self?.onConfirm?()
        }
    }
}
