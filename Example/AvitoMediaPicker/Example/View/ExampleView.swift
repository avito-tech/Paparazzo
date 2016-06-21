import UIKit

final class ExampleView: UIView {
    
    var onShowMediaPickerButtonTap: (() -> ())?
    var onShowPhotoLibraryButtonTap: (() -> ())?
    
    private let mediaPickerButton = UIButton()
    private let photoLibraryButton = UIButton()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        mediaPickerButton.setTitle("Show Media Picker", forState: .Normal)
        mediaPickerButton.addTarget(
            self,
            action: #selector(ExampleView.onShowMediaPickerButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        photoLibraryButton.setTitle("Show Photo Library", forState: .Normal)
        photoLibraryButton.addTarget(
            self,
            action: #selector(ExampleView.onShowPhotoLibraryButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        addSubview(mediaPickerButton)
        addSubview(photoLibraryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mediaPickerButton.sizeToFit()
        mediaPickerButton.center = CGPoint(x: bounds.center.x, y: bounds.center.y - 30)
        
        photoLibraryButton.sizeToFit()
        photoLibraryButton.center = CGPoint(x: bounds.center.x, y: bounds.center.y + 30)
    }
    
    // MARK: - Private
    
    @objc private func onShowMediaPickerButtonTap(sender: UIButton) {
        onShowMediaPickerButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryButtonTap(sender: UIButton) {
        onShowPhotoLibraryButtonTap?()
    }
}