import Foundation
import AvitoDesignKit

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
    var onConfirm: (ImageSource -> ())?
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setTitle("Кадрирование")
        view?.setMinimumRotation(-25)
        view?.setMaximumRotation(+25)
        
        setGridVisible(false)
        
        view?.onRotationAngleChange = { [weak self] angle in
            self?.setImageRotation(angle)
        }
        
        view?.onRotateButtonTap = { [weak self] in
            self?.view?.turnImageCounterclockwise()
        }
        
        view?.onRotationCancelButtonTap = { [weak self] in
            self?.view?.setRotationSliderValue(0)
            self?.setImageRotation(0)
        }
        
        view?.onCroppingParametersChange = { [weak self] parameters in
            self?.interactor.setCroppingParameters(parameters)
        }
        
        view?.onDiscardButtonTap = { [weak self] in
            self?.onDiscard?()
        }
        
        view?.onConfirmButtonTap = { [weak self] previewImage in
            self?.interactor.croppedImage(previewImage: previewImage) { image in
                self?.onConfirm?(image)
            }
        }
        
        interactor.canvasSize { [weak self] canvasSize in
            self?.view?.setCanvasSize(canvasSize)
        }
        
        interactor.croppedImageAspectRatio { [weak self] aspectRatio in
            
            let isPortrait = aspectRatio < 1
            
            self?.setAspectRatio(isPortrait ? .portrait_3x4 : .landscape_4x3)
            
            self?.interactor.originalImageWithParameters { originalImage, croppingParameters in
                self?.view?.setImage(originalImage) {
                    if let croppingParameters = croppingParameters {
                        
                        self?.view?.setCroppingParameters(croppingParameters)
                        
                        let angleInDegrees = Float(croppingParameters.tiltAngle).radiansToDegrees()
                        self?.view?.setRotationSliderValue(angleInDegrees)
                        self?.adjustCancelRotationButtonForAngle(angleInDegrees)
                    }
                }
            }
        }
    }
    
    private func setImageRotation(angle: Float) {
        view?.setImageTiltAngle(angle)
        adjustCancelRotationButtonForAngle(angle)
    }
    
    private func adjustCancelRotationButtonForAngle(angle: Float) {
        
        let displayedAngle = Int(round(angle))
        let shouldShowCancelRotationButton = (displayedAngle != 0)
        
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
    
    private func setAspectRatio(aspectRatio: AspectRatio) {
        
        view?.setAspectRatio(aspectRatio)
        view?.setAspectRatioButtonTitle(aspectRatioButtonTitle(for: aspectRatio))
        
        view?.onAspectRatioButtonTap = { [weak self] in
            if let nextRatio = self?.aspectRatioAfter(aspectRatio) {
                self?.setAspectRatio(nextRatio)
            }
        }
    }
    
    private func aspectRatioButtonTitle(for aspectRatio: AspectRatio) -> String {
        switch aspectRatio {
        case .portrait_3x4:
            return "3:4"
        case .landscape_4x3:
            return "4:3"
        }
    }
    
    private func aspectRatioAfter(aspectRatio: AspectRatio) -> AspectRatio {
        switch aspectRatio {
        case .portrait_3x4:
            return .landscape_4x3
        case .landscape_4x3:
            return .portrait_3x4
        }
    }
}
