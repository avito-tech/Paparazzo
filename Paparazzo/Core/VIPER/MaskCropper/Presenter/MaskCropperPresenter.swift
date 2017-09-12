import ImageSource

final class MaskCropperPresenter: MaskCropperModule {
    
    private let interactor: MaskCropperInteractor
    private let router: MaskCropperRouter
    
    weak var view: MaskCropperViewInput? {
        didSet {
            setUpView()
        }
    }
    
    init(interactor: MaskCropperInteractor, router: MaskCropperRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func setUpView() {
        
        view?.onDiscardTap = { [weak self] in
            self?.onDiscard?()
        }
        
        view?.onCroppingParametersChange = { [weak self] parameters in
            self?.interactor.setCroppingParameters(parameters)
        }
        
        view?.onConfirmTap = { [weak self] previewImage in
            if let previewImage = previewImage {
                self?.interactor.croppedImage(previewImage: previewImage) { image in
                    self?.onConfirm?(image)
                }
            } else {
                self?.onDiscard?()
            }
        }
        
        interactor.canvasSize { [weak self] canvasSize in
            self?.view?.setCanvasSize(canvasSize)
        }
        
        interactor.imageWithParameters { [weak self] data in
            self?.view?.setImage(data.originalImage, previewImage: data.previewImage) {
                self?.view?.setControlsEnabled(true)
                
                if let croppingParameters = data.parameters {
                    self?.view?.setCroppingParameters(croppingParameters)
                }
            }
        }
    }
    
    var onDiscard: (() -> ())?
    var onConfirm: ((ImageSource) -> ())?
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
}
