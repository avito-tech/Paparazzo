import ImageSource
import UIKit

final class CroppingPreviewView: UIView {
    private static let greatestFiniteMagnitudeSize = CGSize(
        width: CGFloat.greatestFiniteMagnitude,
        height: CGFloat.greatestFiniteMagnitude
    )
    
    /// Максимальный размер оригинальной картинки. Если меньше размера самой картинки, она будет даунскейлиться.
    private var sourceImageMaxSize = CroppingPreviewView.greatestFiniteMagnitudeSize
    
    private let previewView = PhotoTweakView()
    
    // MARK: - Private
    
    private var aspectRatio: AspectRatio = .portrait_3x4
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        addSubview(previewView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewView.frame = bounds
    }
    
    // MARK: - CroppingPreviewView
    
    var cropAspectRatio: CGFloat {
        get { return previewView.cropAspectRatio }
        set { previewView.cropAspectRatio = newValue }
    }
    
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? {
        get { return previewView.onCroppingParametersChange }
        set { previewView.onCroppingParametersChange = newValue }
    }
    
    var onPreviewImageWillLoading: (() -> ())?
    var onPreviewImageDidLoad: ((UIImage) -> ())?
    var onImageDidLoad: (() -> ())?
    
    func setMaskVisible(_ visible: Bool) {
        previewView.setMaskVisible(visible)
    }
    
    func setImage(_ image: ImageSource, previewImage: ImageSource?, completion: (() -> ())?) {
        
        if let previewImage = previewImage {
            
            let screenSize = UIScreen.main.bounds.size
            
            let previewOptions = ImageRequestOptions(size: .fitSize(screenSize), deliveryMode: .progressive)

            onPreviewImageWillLoading?()
            
            previewImage.requestImage(options: previewOptions) { [weak self] (result: ImageRequestResult<UIImage>) in
                if let image = result.image {
                    self?.onPreviewImageDidLoad?(image)
                }
            }
        }
        
        let imageSizeOption: ImageSizeOption = (sourceImageMaxSize == CroppingPreviewView.greatestFiniteMagnitudeSize)
            ? .fullResolution
            : .fitSize(sourceImageMaxSize)
        
        let options = ImageRequestOptions(size: imageSizeOption, deliveryMode: .best)
        
        image.requestImage(options: options) { [weak self] (result: ImageRequestResult<UIImage>) in
            if let image = result.image {
                self?.previewView.setImage(image)
                self?.onImageDidLoad?()
            }
            completion?()
        }
    }
    
    func setImageTiltAngle(_ angle: Float) {
        previewView.setTiltAngle(angle.degreesToRadians())
    }
    
    func turnCounterclockwise() {
        previewView.turnCounterclockwise()
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        previewView.setCroppingParameters(parameters)
    }
    
    func setGridVisible(_ visible: Bool) {
        previewView.setGridVisible(visible)
    }
    
    func setCanvasSize(_ size: CGSize) {
        sourceImageMaxSize = size
    }
    
    func cropPreviewImage() -> CGImage? {
        return previewView.cropPreviewImage()
    }
}
