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
        
        view?.setTitle("Кадрирование")
        view?.setMinimumRotation(-25)
        view?.setMaximumRotation(+25)
        
        setAspectRatioButtonMode(.Portrait)
        setGridVisible(false)
        
        view?.onDiscardButtonTap = { [weak self] in
            self?.onDiscard?()
        }
        
        view?.onConfirmButtonTap = { [weak self] in
            self?.onConfirm?()
        }
        
        view?.onRotationAngleChange = { [weak self] angle in
            
            let displayedAngle = Int(round(angle))
            let shouldShowCancelRotationButton = (displayedAngle != 0)
            
            self?.view?.setImageRotation(angle)
            self?.view?.setCancelRotationButtonTitle("\(displayedAngle)°")
            self?.view?.setCancelRotationButtonVisible(shouldShowCancelRotationButton)
        }
        
        view?.onRotateButtonTap = { [weak self] in
            debugPrint("onRotateButtonTap")
        }
    }
    
    private func setGridVisible(visible: Bool) {
        
        view?.setGridVisible(visible)
        view?.setGridButtonSelected(visible)
        
        view?.onGridButtonTap = { [weak self] in
            debugPrint("onGridButtonTap")
            self?.setGridVisible(!visible)
        }
    }
    
    private func setAspectRatioButtonMode(mode: AspectRatioMode) {
        
        view?.setAspectRatioButtonMode(mode)
        view?.setAspectRatioButtonTitle(aspectRatioButtonTitleForMode(mode))
        
        adjustStencilForMode(mode)
        
        view?.onAspectRatioButtonTap = { [weak self] in
            if let nextMode = self?.aspectRationButtonTitleModeAfterMode(mode) {
                self?.setAspectRatioButtonMode(nextMode)
            }
        }
    }
    
    private func aspectRatioButtonTitleForMode(mode: AspectRatioMode) -> String {
        switch mode {
        case .Portrait:
            return "3:4"
        case .Landscape:
            return "4:3"
        }
    }
    
    private func aspectRationButtonTitleModeAfterMode(mode: AspectRatioMode) -> AspectRatioMode {
        switch mode {
        case .Portrait:
            return .Landscape
        case .Landscape:
            return .Portrait
        }
    }
    
    private func adjustStencilForMode(mode: AspectRatioMode) {
        switch mode {
        case .Portrait:
            view?.hideStencil()
        case .Landscape:
            view?.showStencilForAspectRatioMode(mode)
        }
    }
}
