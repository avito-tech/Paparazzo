import UIKit

final class ExampleView: UIView {
    
    private let mediaPickerButton = UIButton()
    private let maskCropperButton = UIButton()
    private let photoLibraryButton = UIButton()
    private let photoLibraryV2Button = UIButton()
    private let scannerButton = UIButton()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        mediaPickerButton.setTitle("Show Media Picker", for: .normal)
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
        
        photoLibraryV2Button.setTitle("Show Photo Library V2", for: .normal)
        photoLibraryV2Button.addTarget(
            self,
            action: #selector(onShowPhotoLibraryV2ButtonTap(_:)),
            for: .touchUpInside
        )
        
        scannerButton.setTitle("Show Scanner", for: .normal)
        scannerButton.addTarget(
            self,
            action: #selector(onShowScannerButtonTap(_:)),
            for: .touchUpInside
        )
        
        addSubview(mediaPickerButton)
        addSubview(maskCropperButton)
        addSubview(photoLibraryButton)
        addSubview(photoLibraryV2Button)
        addSubview(scannerButton)
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
    
    func setPhotoLibraryV2ButtonTitle(_ title: String) {
        photoLibraryV2Button.setTitle(title, for: .normal)
    }
    
    func setScannerButtonTitle(_ title: String) {
        scannerButton.setTitle(title, for: .normal)
    }
    
    var onShowMediaPickerButtonTap: (() -> ())?
    var onShowMaskCropperButtonTap: (() -> ())?
    var onShowPhotoLibraryButtonTap: (() -> ())?
    var onShowPhotoLibraryV2ButtonTap: (() -> ())?
    var onShowScannerButtonTap: (() -> ())?
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mediaPickerButton.sizeToFit()
        mediaPickerButton.center = CGPoint(x: bounds.midX, y: bounds.midY - 60)
        
        maskCropperButton.sizeToFit()
        maskCropperButton.center = CGPoint(x: bounds.midX, y: bounds.midY - 30)
        
        photoLibraryButton.sizeToFit()
        photoLibraryButton.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        photoLibraryV2Button.sizeToFit()
        photoLibraryV2Button.center = CGPoint(x: bounds.midX, y: bounds.midY + 30)
        
        scannerButton.sizeToFit()
        scannerButton.center = CGPoint(x: bounds.midX, y: bounds.midY + 60)
    }
    
    // MARK: - Private
    
    @objc private func onShowMediaPickerButtonTap(_: UIButton) {
        onShowMediaPickerButtonTap?()
    }
    
    @objc private func onMaskCropperButtonTap(_: UIButton) {
        onShowMaskCropperButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryButtonTap(_: UIButton) {
        onShowPhotoLibraryButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryV2ButtonTap(_: UIButton) {
        onShowPhotoLibraryV2ButtonTap?()
    }
    
    @objc private func onShowScannerButtonTap(_: UIButton) {
        onShowScannerButtonTap?()
    }
}
