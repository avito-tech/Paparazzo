import UIKit

final class ExampleView: UIView {
    
    private let mediaPickerButton = UIButton()
    private let maskCropperButton = UIButton()
    private let photoLibraryButton = UIButton()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        mediaPickerButton.addTarget(
            self,
            action: #selector(onShowMediaPickerButtonTap(_:)),
            for: .touchUpInside
        )
        
        maskCropperButton.setTitle("Show Mask Cropper", for: .normal)
        maskCropperButton.addTarget(
            self,
            action: #selector(onMaskCropperButtonTap(_:)),
            for: .touchUpInside
        )
        
        photoLibraryButton.setTitle("Show Photo Library", for: .normal)
        photoLibraryButton.addTarget(
            self,
            action: #selector(onShowPhotoLibraryButtonTap(_:)),
            for: .touchUpInside
        )
        
        addSubview(mediaPickerButton)
        addSubview(maskCropperButton)
        addSubview(photoLibraryButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ExampleView
    
    func setMediaPickerButtonTitle(_ title: String) {
        mediaPickerButton.setTitle(title, for: .normal)
    }
    
    func setMaskCropperButtonTitle(_ title: String) {
        maskCropperButton.setTitle(title, for: .normal)
    }
    
    func setPhotoLibraryButtonTitle(_ title: String) {
        photoLibraryButton.setTitle(title, for: .normal)
    }
    
    var onShowMediaPickerButtonTap: (() -> ())?
    var onMaskCropperButtonTap: (() -> ())?
    var onShowPhotoLibraryButtonTap: (() -> ())?
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mediaPickerButton.sizeToFit()
        mediaPickerButton.center = CGPoint(x: bounds.midX, y: bounds.midY - 50)
        
        maskCropperButton.sizeToFit()
        maskCropperButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        photoLibraryButton.sizeToFit()
        photoLibraryButton.center = CGPoint(x: bounds.midX, y: bounds.midY + 50)
    }
    
    // MARK: - Private
    
    @objc private func onShowMediaPickerButtonTap(_: UIButton) {
        onShowMediaPickerButtonTap?()
    }
    
    @objc private func onMaskCropperButtonTap(_: UIButton) {
        onMaskCropperButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryButtonTap(_: UIButton) {
        onShowPhotoLibraryButtonTap?()
    }
}
