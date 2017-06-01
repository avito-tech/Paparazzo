import ImageSource
import UIKit

final class MaskCropperView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MaskCropperUITheme
    
    private let overlayView: MaskCropperOverlayView
    private let controlsView = MaskCropperControlsView()
    private let previewView = CroppingPreviewView()
    
    // MARK: - Constants
    
    private let aspectRatio = CGFloat(1)
    private let controlsExtendedHeight = CGFloat(80)
    
    // MARK: - Init
    
    init(croppingOverlayProvider: CroppingOverlayProvider) {
        
        overlayView = MaskCropperOverlayView(
            croppingOverlayProvider: croppingOverlayProvider
        )
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        clipsToBounds = true
        
        previewView.setGridVisible(false)
        previewView.setMaskVisible(false)
        previewView.cropAspectRatio = aspectRatio
        
        addSubview(previewView)
        addSubview(overlayView)
        addSubview(controlsView)
        
        overlayView.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: MaskCropperUITheme) {
        controlsView.setTheme(theme)
    }
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        
        previewView.width = width
        previewView.height = height - controlsExtendedHeight
        
        overlayView.frame = previewView.frame
        
        controlsView.top = previewView.bottom
        controlsView.width = width
        controlsView.height = controlsExtendedHeight
    }
    
    // MARK: - MaskCropperView
    
    var onConfirmTap: ((_ previewImage: CGImage?) -> ())? {
        didSet {
            controlsView.onConfirmTap = { [weak self] in
                self?.onConfirmTap?(self?.previewView.cropPreviewImage())
            }
        }
    }
    
    var onDiscardTap: (() -> ())? {
        get { return controlsView.onDiscardTap }
        set { controlsView.onDiscardTap = newValue }
    }
    
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? {
        get { return previewView.onCroppingParametersChange }
        set { previewView.onCroppingParametersChange = newValue }
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        previewView.setCroppingParameters(parameters)
    }
    
    func setImage(_ imageSource: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ()) {
        previewView.setImage(imageSource, previewImage: previewImage, completion: completion)
    }
    
    func setCanvasSize(_ canvasSize: CGSize) {
        previewView.setCanvasSize(canvasSize)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        controlsView.setControlsEnabled(enabled)
    }
    
}
