import UIKit

final class ImageCroppingView: UIView {
    
    // MARK: - Subviews
    
    private let controlsView: ImageCroppingControlsView
    private let previewView: ZoomingImageView   // TODO: надо заюзать что-то другое, например, CATiledLayer. Короче, поискать готовое решение.
    private let stencilView: UIView
    private let aspectRatioButton: UIButton
    private let titleLabel: UILabel
    
    // MARK: - Constants
    
    private let photoAspectRatio = CGFloat(3.0 / 4.0)
    private let controlsHeight = CGFloat(165)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        
        controlsView = ImageCroppingControlsView()
        previewView = ZoomingImageView()
        stencilView = UIView()
        aspectRatioButton = UIButton()
        titleLabel = UILabel()
        
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        addSubview(previewView)
        addSubview(controlsView)
        addSubview(stencilView)
        addSubview(titleLabel)
        addSubview(aspectRatioButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.size.width,
            height: bounds.size.width / photoAspectRatio
        )
        
        controlsView.frame = CGRect(x: 0, y: bounds.bottom - 165, width: bounds.size.width, height: 165)
    }
    
    // MARK: - ImageCroppingView
    
    var onDiscardButtonTap: (() -> ())? {
        get { return controlsView.onDiscardButtonTap }
        set { controlsView.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: (() -> ())? {
        get { return controlsView.onConfirmButtonTap }
        set { controlsView.onConfirmButtonTap = newValue }
    }
    
    func setImage(image: ImageSource) {
        image.fullResolutionImage { [weak self] (image: UIImage?) in
            self?.previewView.image = image
        }
    }
    
    func setTheme(theme: ImageCroppingUITheme) {
        controlsView.setTheme(theme)
    }
}