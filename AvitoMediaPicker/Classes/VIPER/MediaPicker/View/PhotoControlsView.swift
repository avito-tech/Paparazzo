import UIKit

final class PhotoControlsView: UIView {
    
    // MARK: - Subviews
    
    private let removeButton = UIButton()
    private let cropButton = UIButton()
    private let cameraButton = UIButton()
    
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
        
        cameraButton.addTarget(
            self,
            action: #selector(PhotoControlsView.onCameraButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        addSubview(removeButton)
        addSubview(cropButton)
        addSubview(cameraButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sidePadding = CGFloat(75)
        let numberOfButtons = CGFloat(3)
        let interbuttonSpacing = (bounds.size.width - 2 * sidePadding) / (numberOfButtons - 1)
        
        removeButton.sizeToFit()
        removeButton.height = removeButton.width
        removeButton.centerY = bounds.centerY
        
        cropButton.sizeToFit()
        cropButton.height = cropButton.width
        cropButton.centerY = bounds.centerY
        
        cameraButton.sizeToFit()
        cameraButton.height = cameraButton.width
        cameraButton.centerY = bounds.centerY
        
        var x = sidePadding
        
        [removeButton, cropButton, cameraButton].forEach { button in
            button.centerX = x
            x += interbuttonSpacing
        }
    }
    
    // MARK: - PhotoControlsView
    
    var onRemoveButtonTap: (() -> ())?
    var onCropButtonTap: (() -> ())?
    var onCameraButtonTap: (() -> ())?
    
    func setControlsTransform(transform: CGAffineTransform) {
        removeButton.transform = transform
        cropButton.transform = transform
        cameraButton.transform = transform
    }
    
    func setColors(colors: MediaPickerColors) {
        // TODO
    }
    
    func setImages(images: MediaPickerImages) {
        removeButton.setImage(images.removePhotoIcon(), forState: .Normal)
        cropButton.setImage(images.cropPhotoIcon(), forState: .Normal)
        cameraButton.setImage(images.returnToCameraIcon(), forState: .Normal)
    }
    
    // MARK: - Private
    
    @objc private func onRemoveButtonTap(sender: UIButton) {
        onRemoveButtonTap?()
    }
    
    @objc private func onCropButtonTap(sender: UIButton) {
        onCropButtonTap?()
    }
    
    @objc private func onCameraButtonTap(sender: UIButton) {
        onCameraButtonTap?()
    }
}
