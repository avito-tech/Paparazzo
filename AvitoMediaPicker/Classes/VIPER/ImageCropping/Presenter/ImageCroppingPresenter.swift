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
        
        setAspectRatioButtonMode(.Portrait_3x4)
        setGridVisible(false)
        
        view?.onDiscardButtonTap = { [weak self] in
            self?.onDiscard?()
        }
        
        view?.onConfirmButtonTap = { [weak self] in
            self?.onConfirm?()
        }
        
        view?.onRotationAngleChange = { [weak self] angle in
            self?.setImageRotation(angle)
        }
        
        view?.onRotateButtonTap = { [weak self] in
            debugPrint("onRotateButtonTap")
            // TODO
        }
        
        view?.onRotationCancelButtonTap = { [weak self] in
            self?.view?.setRotationSliderValue(0)
            self?.setImageRotation(0)
        }
    }
    
    private func setImageRotation(angle: Float) {
        
        let displayedAngle = Int(round(angle))
        let shouldShowCancelRotationButton = (displayedAngle != 0)
        
        view?.setImageRotation(angle)
        view?.setCancelRotationButtonTitle("\(displayedAngle > 0 ? "+" : "")\(displayedAngle)°")
        view?.setCancelRotationButtonVisible(shouldShowCancelRotationButton)
    }
    
    private func setGridVisible(visible: Bool) {
        
        view?.setGridVisible(visible)
        view?.setGridButtonSelected(visible)
        
        view?.onGridButtonTap = { [weak self] in
            self?.setGridVisible(!visible)
        }
    }
    
    private func setAspectRatioButtonMode(mode: AspectRatioMode) {
        
        view?.setAspectRatioMode(mode)
        view?.setAspectRatioButtonTitle(aspectRatioButtonTitleForMode(mode))
        
        view?.onAspectRatioButtonTap = { [weak self] in
            if let nextMode = self?.aspectRationButtonTitleModeAfterMode(mode) {
                self?.setAspectRatioButtonMode(nextMode)
            }
        }
    }
    
    private func aspectRatioButtonTitleForMode(mode: AspectRatioMode) -> String {
        switch mode {
        case .Portrait_3x4:
            return "3:4"
        case .Landscape_4x3:
            return "4:3"
        }
    }
    
    private func aspectRationButtonTitleModeAfterMode(mode: AspectRatioMode) -> AspectRatioMode {
        switch mode {
        case .Portrait_3x4:
            return .Landscape_4x3
        case .Landscape_4x3:
            return .Portrait_3x4
        }
    }
}
