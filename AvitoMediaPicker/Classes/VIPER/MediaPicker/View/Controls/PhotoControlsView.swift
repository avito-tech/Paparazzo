import UIKit

final class PhotoControlsView: UIView {
    
    // MARK: - Subviews
    
    private let removeButton = UIButton()
    private let cropButton = UIButton()
    
    // MARK: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        
        removeButton.addTarget(
            self,
            action: #selector(PhotoControlsView.onRemoveButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        cropButton.addTarget(
            self,
            action: #selector(PhotoControlsView.onCropButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        addSubview(removeButton)
        addSubview(cropButton)    // в первой итерации не показываем
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        removeButton.sizeToFit()
        cropButton.sizeToFit()
        
        if cropButton.hidden {
            removeButton.center = bounds.center
        } else {
            removeButton.center = CGPoint(x: bounds.left + 100, y: bounds.centerY)
            cropButton.center = CGPoint(x: bounds.right - 100, y: bounds.centerY)
        }
    }
    
    // MARK: - PhotoControlsView
    
    var onRemoveButtonTap: (() -> ())?
    var onCropButtonTap: (() -> ())?
    var onCameraButtonTap: (() -> ())?
    
    func setControlsTransform(transform: CGAffineTransform) {
        removeButton.transform = transform
        cropButton.transform = transform
    }
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {
        removeButton.setImage(theme.removePhotoIcon, forState: .Normal)
        cropButton.setImage(theme.cropPhotoIcon, forState: .Normal)
    }
    
    func setShowsCropButton(showsCropButton: Bool) {
        cropButton.hidden = !showsCropButton
        setNeedsLayout()
    }
    
    // MARK: - Private
    
    @objc private func onRemoveButtonTap(sender: UIButton) {
        onRemoveButtonTap?()
    }
    
    @objc private func onCropButtonTap(sender: UIButton) {
        onCropButtonTap?()
    }
}
