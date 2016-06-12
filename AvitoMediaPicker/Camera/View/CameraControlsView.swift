import UIKit
import AvitoDesignKit

final class CameraControlsView: UIView {
    
    var onShutterButtonTap: (() -> ())?
    var onFlashToggle: (Bool -> ())?
    
    // MARK: - Subviews
    
    private let photoView = UIImageView()
    private let shutterButton = UIButton()
    private let flashButton = UIButton()
    
    // MARK: - Constants
    
    private let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    
    private let shutterButtonMinDiameter = CGFloat(44)
    private let shutterButtonMaxDiameter = CGFloat(64)
    
    private let photoViewDiameter = CGFloat(44)
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        photoView.backgroundColor = .lightGrayColor()
        photoView.layer.cornerRadius = photoViewDiameter / 2
        photoView.clipsToBounds = true
        
        shutterButton.backgroundColor = .blueColor()    // TODO
        shutterButton.addTarget(
            self,
            action: #selector(CameraControlsView.onShutterButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        flashButton.hidden = true
        flashButton.setTitle("ПЫЩ", forState: .Normal)  // TODO
        flashButton.setTitleColor(.lightGrayColor(), forState: .Normal)
        flashButton.setTitleColor(.blueColor(), forState: .Selected)
        flashButton.addTarget(
            self,
            action: #selector(CameraControlsView.onFlashButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        addSubview(photoView)
        addSubview(shutterButton)
        addSubview(flashButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentHeight = bounds.shrinked(insets).size.height
        let shutterButtonDiameter = max(shutterButtonMinDiameter, min(shutterButtonMaxDiameter, contentHeight))
        let shutterButtonSize = CGSize(width: shutterButtonDiameter, height: shutterButtonDiameter)
        
        shutterButton.frame = CGRect(origin: .zero, size: shutterButtonSize)
        shutterButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        shutterButton.layer.cornerRadius = shutterButtonDiameter / 2
        
        let flashButtonSize = flashButton.sizeThatFits(bounds.size)
        flashButton.size = CGSize(width: flashButtonSize.width, height: flashButtonSize.width)
        flashButton.right = bounds.right - insets.right
        flashButton.centerY = bounds.centerY
        
        photoView.size = CGSize(width: photoViewDiameter, height: photoViewDiameter)
        photoView.left = bounds.left + insets.left
        photoView.centerY = bounds.centerY
    }
    
    // MARK: - CameraControlsView
    
    func setControlsTransform(transform: CGAffineTransform) {
        flashButton.transform = transform
        photoView.transform = transform
    }
    
    func setLatestPhotoLibraryItemImage(image: AbstractImage?) {
        
        if let image = image {
        
            let thumbnailSize = CGSize(width: photoViewDiameter, height: photoViewDiameter)
            
            image.imageFittingSize(thumbnailSize) { [weak photoView] (image: UIImage?) in
                photoView?.image = image
            }
            
        } else {
            photoView.image = nil
        }
    }
    
    func setFlashButtonVisible(visible: Bool) {
        flashButton.hidden = !visible
    }
    
    // MARK: - Private
    
    @objc private func onShutterButtonTap(button: UIButton) {
        onShutterButtonTap?()
    }
    
    @objc private func onFlashButtonTap(button: UIButton) {
        button.selected = !button.selected
        onFlashToggle?(button.selected)
    }
}
