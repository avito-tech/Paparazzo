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
    private let flashView = UIView()
    private let snapshotView = UIImageView()
    
    // TODO: extract to separate view
    private let previewView = UIView()
    private let viewfinderBorderView = CameraViewfinderBorderView()
    
    // MARK: - Specs
    private let navigationBarHeight = CGFloat(52)
    private let captureButtonSize = CGFloat(64)
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        hintLabel.text = "Разместите объект внутри рамки и сделайте фото"
        
        addSubview(previewView)
        addSubview(flashView)
        addSubview(closeButton)
        addSubview(photoLibraryButton)
        addSubview(captureButton)
        addSubview(flashButton)
        addSubview(toggleCameraButton)
        addSubview(hintLabel)
        addSubview(selectedPhotosBarView)
        addSubview(snapshotView)
        
        snapshotView.contentMode = .scaleAspectFill
        snapshotView.layer.cornerRadius = 10
        snapshotView.layer.masksToBounds = true
        snapshotView.isHidden = true
        
        flashView.backgroundColor = .white
        flashView.alpha = 0
        
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
        
        toggleCameraButton.setImage(
            UIImage(named: "back_front_new", in: Resources.bundle, compatibleWith: nil),
            for: .normal
        )
        toggleCameraButton.addTarget(self, action: #selector(handleToggleCameraButtonTap), for: .touchUpInside)
        toggleCameraButton.sizeToFit()
        
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
    var onToggleCameraButtonTap: (() -> ())?
    
    var onDoneButtonTap: (() -> ())? {
        get { return selectedPhotosBarView.onButtonTap }
        set { selectedPhotosBarView.onButtonTap = newValue }
    }
    
    func setCaptureSession(_ captureSession: AVCaptureSession?) {
        previewLayer.session = captureSession
    }
    
    func setSelectedPhotosBarState(_ state: SelectedPhotosBarState, completion: @escaping () -> ()) {
        switch state {
        case .hidden:
            selectedPhotosBarView.isHidden = true
            completion()
        case .visible(let data):
            selectedPhotosBarView.isHidden = false
            selectedPhotosBarView.label.text = data.countString
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            selectedPhotosBarView.lastPhotoThumbnailView.setImage(
                fromSource: data.lastPhoto,
                resultHandler: { result in
                    // TODO: fix possible but with leaving more times than entering
                    if !result.degraded {
                        dispatchGroup.leave()
                    }
                }
            )
            
            dispatchGroup.enter()
            selectedPhotosBarView.penultimatePhotoThumbnailView.setImage(
                fromSource: data.penultimatePhoto,
                resultHandler: { result in
                    // TODO: fix possible but with leaving more times than entering
                    if !result.degraded {
                        dispatchGroup.leave()
                    }
                }
            )
            
            dispatchGroup.notify(queue: .main, execute: completion)
        }
    }
    
    func animateFlash() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.flashView.alpha = 1
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0.1,
                    options: [.curveEaseOut],
                    animations: {
                        self.flashView.alpha = 0
                    },
                    completion: nil
                )
            }
        )
    }
    
    func animateTakenPhoto(
        _ image: ImageSource,
        completion: @escaping (_ finalizeAnimation: @escaping () -> ()) -> ())
    {
        let sideInsets = CGFloat(18)
        let snapshotWidthToHeightRatio = CGFloat(4) / 3
        let snapshotInitialWidth = previewView.width - 2 * sideInsets
        let snapshotInitialHeight = snapshotInitialWidth / snapshotWidthToHeightRatio
        
        let snapshotFinalFrame = convert(
            selectedPhotosBarView.lastPhotoThumbnailView.frame,
            from: selectedPhotosBarView.lastPhotoThumbnailView.superview
        )
        
        snapshotView.frame = CGRect(
            x: previewView.left + sideInsets,
            y: previewView.top + (previewView.height - snapshotInitialHeight) / 2,
            width: snapshotInitialWidth,
            height: snapshotInitialHeight
        )
        snapshotView.layer.cornerRadius = 10
        snapshotView.isHidden = false
        
        snapshotView.setImage(
            fromSource: image,
            resultHandler: { result in
                guard !result.degraded else { return }
                
                UIView.animate(
                    withDuration: 1,
                    delay: 1,
                    options: [],
                    animations: {
                        self.snapshotView.frame = snapshotFinalFrame
                        self.layer.cornerRadius = self.selectedPhotosBarView.lastPhotoThumbnailView.layer.cornerRadius
                    },
                    completion: { _ in
                        completion {
                            self.snapshotView.isHidden = true
                        }
                    }
                )
            }
        )
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
        
        flashView.frame = previewView.frame
        
        toggleCameraButton.right = bounds.right - 23
        toggleCameraButton.centerY = captureButton.centerY
        
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
    
    @objc private func handleToggleCameraButtonTap() {
        onToggleCameraButtonTap?()
    }
}
