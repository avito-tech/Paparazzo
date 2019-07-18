import AVFoundation
import ImageSource
import UIKit

enum SelectedPhotosBarState {
    case hidden
    case visible(SelectedPhotosBarData)
}

struct SelectedPhotosBarData { // TODO: make final class
    let lastPhoto: ImageSource?
    let penultimatePhoto: ImageSource?
    let countString: String
}

final class NewCameraView: UIView {
    
    // MARK: - Subviews
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let closeButton = UIButton()
    private let photoLibraryButton = UIButton()
    private let captureButton = UIButton()
    private let flashButton = UIButton()
    private let toggleCameraButton = UIButton()
    private let hintLabel = UILabel()
    private let selectedPhotosBarView = SelectedPhotosBarView()
    
    // TODO: extract to separate view
    private let previewView = UIView()
    private let viewfinderBorderView = CameraViewfinderBorderView()
    
    // MARK: - Specs
    private let navigationBarHeight = CGFloat(52)
    private let captureButtonSize = CGFloat(58)
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        hintLabel.text = "Разместите объект внутри рамки и сделайте фото"
        
        addSubview(previewView)
        addSubview(closeButton)
        addSubview(photoLibraryButton)
        addSubview(captureButton)
        addSubview(flashButton)
        addSubview(toggleCameraButton)
        addSubview(hintLabel)
        addSubview(selectedPhotosBarView)
        
        closeButton.setImage(
            UIImage(named: "bt-close", in: Resources.bundle, compatibleWith: nil),
            for: .normal
        )
        closeButton.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
        closeButton.sizeToFit()
        
        captureButton.layer.cornerRadius = captureButtonSize / 2
        captureButton.layer.borderColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1).cgColor
        captureButton.layer.borderWidth = 6
        captureButton.addTarget(self, action: #selector(handleCaptureButtonTap), for: .touchUpInside)
        
        previewView.layer.masksToBounds = true
        previewView.layer.addSublayer(previewLayer)
        
        hintLabel.textColor = .gray
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0
        
        selectedPhotosBarView.isHidden = true
        
        previewView.addSubview(viewfinderBorderView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - NewCameraView
    var onCaptureButtonTap: (() -> ())?
    var onCloseButtonTap: (() -> ())?
    
    func setCaptureSession(_ captureSession: AVCaptureSession?) {
        previewLayer.session = captureSession
    }
    
    func setSelectedPhotosBarState(_ state: SelectedPhotosBarState) {
        switch state {
        case .hidden:
            selectedPhotosBarView.isHidden = true
        case .visible(let data):
            selectedPhotosBarView.isHidden = false
            selectedPhotosBarView.label.text = data.countString
            selectedPhotosBarView.lastPhotoThumbnailView.setImage(fromSource: data.lastPhoto)
            selectedPhotosBarView.penultimatePhotoThumbnailView.setImage(fromSource: data.penultimatePhoto)
        }
    }
    
    // MARK: - UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.left = 8
        closeButton.centerY = paparazzoSafeAreaInsets.top + navigationBarHeight / 2
        
        captureButton.layout(
            left: bounds.centerX - captureButtonSize / 2,
            right: bounds.centerX + captureButtonSize / 2,
            bottom: bounds.bottom - 114,
            height: captureButtonSize
        )
        
        hintLabel.layout(
            left: bounds.left + 16,
            right: bounds.right - 16,
            bottom: bounds.bottom - 23,
            fitHeight: .greatestFiniteMagnitude
        )
        
        layOutPreview()
        
        selectedPhotosBarView.layout(
            left: bounds.left + 16,
            right: bounds.right - 16,
            bottom: bounds.bottom - 16,
            fitHeight: .greatestFiniteMagnitude
        )
    }
    
    // MARK: - Private - Layout
    private func layOutPreview() {
        
        let previewAspectRatio = CGFloat(3) / 4
        let previewHeight = bounds.width * previewAspectRatio
        
        previewView.frame = CGRect(
            x: 0,
            y: paparazzoSafeAreaInsets.top + navigationBarHeight + (captureButton.top - (bounds.top + navigationBarHeight) - previewHeight) / 2,
            width: bounds.width,
            height: previewHeight
        )
        
        previewLayer.frame = CGRect(
            x: 0,
            y: previewView.bounds.centerY - previewView.width / previewAspectRatio / 2,
            width: previewView.width,
            height: previewView.width / previewAspectRatio
        )
        
        viewfinderBorderView.frame = previewView.bounds
    }
    
    // MARK: - Private - Event handling
    @objc private func handleCaptureButtonTap() {
        onCaptureButtonTap?()
    }
    
    @objc private func handleCloseButtonTap() {
        onCloseButtonTap?()
    }
}
