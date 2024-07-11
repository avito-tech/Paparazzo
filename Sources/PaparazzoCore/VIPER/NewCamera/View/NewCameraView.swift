import AVFoundation
import ImageSource
import UIKit

enum SelectedPhotosBarState {
    case hidden
    case placeholder
    case visible(SelectedPhotosBarData)
}

struct SelectedPhotosBarData { // TODO: make final class
    let lastPhoto: ImageSource?
    let penultimatePhoto: ImageSource?
    let countString: String
}

final class NewCameraView: UIView {
    
    // MARK: - Subviews
    var cameraOutputLayer: AVCaptureVideoPreviewLayer?
    private let closeButton = UIButton()
    private let photoLibraryButton = UIButton()
    private let captureButton = UIButton()
    private let flashButton = UIButton()
    private let toggleCameraButton = UIButton()
    private let hintLabel = UILabel()
    private let selectedPhotosBarView = SelectedPhotosBarView()
    private let flashView = UIView()
    private let snapshotView = UIImageView()
    private let photoView = UIImageView()
    private let accessDeniedView = AccessDeniedView()
    
    // TODO: extract to separate view
    private let previewView = UIView()
    private let viewfinderBorderView = CameraViewfinderBorderView()
    
    // MARK: - Specs
    private let navigationBarHeight = CGFloat(52)
    private let captureButtonSize = CGFloat(64)
    private var captureButtonBorderColorEnabled = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
    private var captureButtonBackgroundColorEnabled = UIColor.white
    private var captureButtonBorderColorDisabled = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    private var captureButtonBackgroundColorDisabled = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        addSubview(previewView)
        addSubview(closeButton)
        addSubview(photoLibraryButton)
        addSubview(captureButton)
        addSubview(photoView)
        addSubview(flashButton)
        addSubview(toggleCameraButton)
        addSubview(hintLabel)
        addSubview(selectedPhotosBarView)
        addSubview(snapshotView)
        addSubview(flashView)
        addSubview(accessDeniedView)
        
        accessDeniedView.isHidden = true
        
        photoView.backgroundColor = .lightGray
        photoView.contentMode = .scaleAspectFill
        photoView.layer.cornerRadius = 18.5
        photoView.clipsToBounds = true
        photoView.isUserInteractionEnabled = true
        photoView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(onPhotoViewTap(_:))
        ))
        
        snapshotView.contentMode = .scaleAspectFill
        snapshotView.layer.cornerRadius = 10
        snapshotView.layer.masksToBounds = true
        snapshotView.isHidden = true
        
        flashView.backgroundColor = .white
        flashView.alpha = 0
        
        closeButton.addTarget(self, action: #selector(handleCloseButtonTap), for: .touchUpInside)
        
        captureButton.layer.cornerRadius = captureButtonSize / 2
        captureButton.layer.borderWidth = 6
        captureButton.addTarget(self, action: #selector(handleCaptureButtonTap), for: .touchUpInside)
        setCaptureButtonState(.enabled)
        
        #if targetEnvironment(simulator)
        previewView.backgroundColor = .black
        #endif
        previewView.layer.masksToBounds = true
        
        flashButton.addTarget(self, action: #selector(handleFlashButtonTap), for: .touchUpInside)
        
        toggleCameraButton.addTarget(self, action: #selector(handleToggleCameraButtonTap), for: .touchUpInside)
        toggleCameraButton.sizeToFit()
        
        hintLabel.textColor = .gray
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 0
        
        selectedPhotosBarView.isHidden = true
        selectedPhotosBarView.accessibilityIdentifier = "selectedPhotosBarView"
        
        previewView.addSubview(viewfinderBorderView)
        
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAccessibilityIds() {
        photoView.setAccessibilityId(.photoView)
        closeButton.setAccessibilityId(.closeButton)
        captureButton.setAccessibilityId(.shutterButton)
        flashButton.setAccessibilityId(.flashButton)
        toggleCameraButton.setAccessibilityId(.cameraToggleButton)
        hintLabel.setAccessibilityId(.cameraHint)
        previewView.setAccessibilityId(.cameraViewfinder)
    }
    
    // MARK: - NewCameraView
    var onCaptureButtonTap: (() -> ())?
    var onCloseButtonTap: (() -> ())?
    var onToggleCameraButtonTap: (() -> ())?
    var onFlashToggle: ((Bool) -> ())?
    
    var onDoneButtonTap: (() -> ())? {
        get { return selectedPhotosBarView.onButtonTap }
        set { selectedPhotosBarView.onButtonTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { return selectedPhotosBarView.onLastPhotoThumbnailTap }
        set { selectedPhotosBarView.onLastPhotoThumbnailTap = newValue }
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    func setTheme(_ theme: NewCameraUITheme) {
        backgroundColor = theme.newCameraViewBackgroundColor
        flashView.backgroundColor = theme.newCameraFlashBackgroundColor
        
        captureButtonBorderColorEnabled = theme.newCameraCaptureButtonBorderColorEnabled
        captureButtonBorderColorDisabled = theme.newCameraCaptureButtonBorderColorDisabled
        captureButtonBackgroundColorEnabled = theme.newCameraCaptureButtonBackgroundColorEnabled
        captureButtonBackgroundColorDisabled = theme.newCameraCaptureButtonBackgroundColorDisabled
        
        closeButton.setImage(theme.newCameraCloseIcon, for: .normal)
        closeButton.tintColor = theme.newCameraButtonTintColor
        
        flashButton.setImage(theme.newCameraFlashOffIcon, for: .normal)
        flashButton.setImage(theme.newCameraFlashOnIcon, for: .selected)
        flashButton.tintColor = theme.newCameraButtonTintColor

        toggleCameraButton.setImage(theme.newCameraToggleCameraIcon, for: .normal)
        toggleCameraButton.tintColor = theme.newCameraButtonTintColor
        
        hintLabel.font = theme.newCameraHintFont
        hintLabel.textColor = theme.newCameraHintTextColor
        
        selectedPhotosBarView.setTheme(theme)
        accessDeniedView.setTheme(theme)
    }
    
    func setSelectedPhotosBarState(_ state: SelectedPhotosBarState, completion: @escaping () -> ()) {
        switch state {
        case .hidden:
            selectedPhotosBarView.isHidden = true
            completion()
        case .placeholder:
            selectedPhotosBarView.isHidden = false
            selectedPhotosBarView.setPlaceholderHidden(false)
        case .visible(let data):
            selectedPhotosBarView.isHidden = false
            selectedPhotosBarView.setPlaceholderHidden(true)
            selectedPhotosBarView.label.text = data.countString
            
            let dispatchGroup = DispatchGroup()
            
            if let lastPhoto = data.lastPhoto {
                var didLeaveGroup = false
                dispatchGroup.enter()
                selectedPhotosBarView.setLastImage(lastPhoto) { result in
                    if !result.degraded && !didLeaveGroup {
                        dispatchGroup.leave()
                        didLeaveGroup = true  // prevent leaving dispatch group more times than entering
                    }
                }
            }
            
            if let penultimatePhoto = data.penultimatePhoto {
                var didLeaveGroup = false
                dispatchGroup.enter()
                selectedPhotosBarView.setPenultimateImage(penultimatePhoto) { result in
                    if !result.degraded && !didLeaveGroup {
                        dispatchGroup.leave()
                        didLeaveGroup = true  // prevent leaving dispatch group more times than entering
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main, execute: completion)
        }
    }
    
    func setHintText(_ hintText: String) {
        hintLabel.text = hintText
    }
    
    func setDoneButtonTitle(_ title: String) {
        selectedPhotosBarView.setDoneButtonTitle(title)
    }
    
    func setPlaceholderText(_ text: String) {
        selectedPhotosBarView.setPlaceholderText(text)
    }
    
    func setLatestPhotoLibraryItemImage(_ imageSource: ImageSource?) {
        photoView.setImage(
            fromSource: imageSource,
            size: CGSize(width: 32, height: 32),
            placeholder: nil,
            placeholderDeferred: false
        )
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
    
    func animateCapturedPhoto(
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
                    withDuration: 0.3,
                    delay: 0.5,
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
    
    func setFlashButtonVisible(_ visible: Bool) {
        flashButton.isHidden = !visible
    }
    
    func setFlashButtonOn(_ isOn: Bool) {
        flashButton.isSelected = isOn
        layOutFlashButton()
    }
    
    func setCaptureButtonState(_ state: CaptureButtonState) {
        captureButton.isEnabled = (state == .enabled)
        
        switch state {
        case .enabled, .nonInteractive:
            captureButton.layer.borderColor = captureButtonBorderColorEnabled.cgColor
            captureButton.layer.backgroundColor = captureButtonBackgroundColorEnabled.cgColor
        case .disabled:
            captureButton.layer.borderColor = captureButtonBorderColorDisabled.cgColor
            captureButton.layer.backgroundColor = captureButtonBackgroundColorDisabled.cgColor
        }
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        self.cameraOutputLayer = previewLayer
        
        if let previewLayer = previewLayer {
            previewView.layer.insertSublayer(previewLayer, below: viewfinderBorderView.layer)
            layOutPreview()
        }
    }
    
    func previewFrame(forBounds bounds: CGRect) -> CGRect {
        return layout(for: bounds).previewViewFrame
    }
    
    func setAccessDeniedViewVisible(_ visible: Bool) {
        accessDeniedView.isHidden = !visible
    }
    
    func setAccessDeniedTitle(_ title: String) {
        accessDeniedView.title = title
    }
    
    func setAccessDeniedMessage(_ message: String) {
        accessDeniedView.message = message
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        accessDeniedView.buttonTitle = title
    }
    
    // MARK: - UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = self.layout(for: bounds)
        
        closeButton.frame = layout.closeButtonFrame
        selectedPhotosBarView.frame = layout.selectedPhotosBarFrame
        captureButton.frame = layout.captureButtonFrame
        hintLabel.frame = layout.hintLabelFrame
        previewView.frame = layout.previewViewFrame
        flashView.frame = layout.flashViewFrame
        toggleCameraButton.frame = layout.toggleCameraButtonFrame
        photoView.frame = layout.photoViewFrame
        accessDeniedView.frame = layout.accessDeniedViewFrame
        
        viewfinderBorderView.frame = previewView.bounds
        
        layOutPreview()
        layOutFlashButton()
    }
    
    // MARK: - Private - Layout
    private struct Layout {
        let closeButtonFrame: CGRect
        let selectedPhotosBarFrame: CGRect
        let captureButtonFrame: CGRect
        let hintLabelFrame: CGRect
        let previewViewFrame: CGRect
        let flashViewFrame: CGRect
        let toggleCameraButtonFrame: CGRect
        let photoViewFrame: CGRect
        let accessDeniedViewFrame: CGRect
    }
    
    private func layout(for bounds: CGRect) -> Layout {
        
        let paparazzoSafeAreaInsets = window?.paparazzoSafeAreaInsets ?? self.paparazzoSafeAreaInsets
        
        let closeButtonFrame = CGRect(
            x: bounds.left + 8,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: 38,
            height: 38
        )
        
        let selectedPhotosBarViewSize = selectedPhotosBarSize(for: bounds)
        let selectedPhotosBarBottom = bounds.bottom - max(16, paparazzoSafeAreaInsets.bottom)
        let selectedPhotosBarViewFrame = CGRect(
            x: bounds.left + floor((bounds.width - selectedPhotosBarViewSize.width) / 2),
            y: selectedPhotosBarBottom - selectedPhotosBarViewSize.height,
            width: selectedPhotosBarViewSize.width,
            height: selectedPhotosBarViewSize.height
        )
        
        let freeHeight = selectedPhotosBarViewFrame.top - closeButtonFrame.bottom
        let previewAspectRatio = CGFloat(3) / 4
        let previewHeight = floor(bounds.width * previewAspectRatio)
        let contentHeight = captureButtonSize + previewHeight
        let spacing = floor((freeHeight - contentHeight) / 3)
        
        let captureButtonBottom = selectedPhotosBarViewFrame.top - spacing
        let captureButtonFrame = CGRect(
            x: floor(bounds.centerX - captureButtonSize / 2),
            y: captureButtonBottom - captureButtonSize,
            width: captureButtonSize,
            height: captureButtonSize
        )
        
        let hintLabelWidth = bounds.width - 2 * 16
        let hintLabelHeight = hintLabel.sizeForWidth(hintLabelWidth).height
        let hintLabelBottom = bounds.bottom - max(23, paparazzoSafeAreaInsets.bottom)
        let hintLabelFrame = CGRect(
            x: bounds.left + 16,
            y: hintLabelBottom - hintLabelHeight,
            width: hintLabelWidth,
            height: hintLabelHeight
        )
        
        let previewViewBottom = captureButtonFrame.top - spacing
        let previewViewFrame = CGRect(
            x: bounds.left,
            y: previewViewBottom - previewHeight,
            width: bounds.width,
            height: previewHeight
        )
        
        let toggleCameraButtonSize = toggleCameraButton.sizeThatFits()
        let toggleCameraButtonRight = bounds.right - 23
        let toggleCameraButtonFrame = CGRect(
            x: toggleCameraButtonRight - toggleCameraButtonSize.width,
            y: floor(captureButtonFrame.centerY - toggleCameraButtonSize.height / 2),
            width: toggleCameraButtonSize.width,
            height: toggleCameraButtonSize.height
        )
        
        let photoViewSize = CGSize(width: 37, height: 37)
        let photoViewFrame = CGRect(
            centerX: bounds.left + floor((captureButtonFrame.left - bounds.left) / 2),
            centerY: captureButtonFrame.centerY,
            width: photoViewSize.width,
            height: photoViewSize.height
        )
        
        let accessDeniedViewMaxSize = CGSize(
            width: bounds.width,
            height: captureButtonFrame.top - closeButtonFrame.bottom
        )
        let accessDeniedViewSize = accessDeniedView.sizeThatFits(accessDeniedViewMaxSize)
        let accessDeniedViewFrame = CGRect(
            centerX: previewViewFrame.centerX,
            centerY: previewViewFrame.centerY,
            width: accessDeniedViewSize.width,
            height: accessDeniedViewSize.height
        )
        
        return Layout(
            closeButtonFrame: closeButtonFrame,
            selectedPhotosBarFrame: selectedPhotosBarViewFrame,
            captureButtonFrame: captureButtonFrame,
            hintLabelFrame: hintLabelFrame,
            previewViewFrame: previewViewFrame,
            flashViewFrame: bounds,
            toggleCameraButtonFrame: toggleCameraButtonFrame,
            photoViewFrame: photoViewFrame,
            accessDeniedViewFrame: accessDeniedViewFrame
        )
    }
    
    private func layOutFlashButton() {
        flashButton.sizeToFit()
        flashButton.right = toggleCameraButton.left - 20
        flashButton.centerY = toggleCameraButton.centerY
    }
    
    private func selectedPhotosBarSize(for bounds: CGRect) -> CGSize {
        let maxSize = CGSize(width: bounds.width - 32, height: .greatestFiniteMagnitude)
        return selectedPhotosBarView.sizeThatFits(maxSize)
    }
    
    private func layOutPreview() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        cameraOutputLayer?.frame = previewView.layer.bounds
        CATransaction.commit()
    }
    
    // MARK: - Private - Event handling
    @objc private func handleCaptureButtonTap() {
        onCaptureButtonTap?()
    }
    
    @objc private func handleCloseButtonTap() {
        onCloseButtonTap?()
    }
    
    @objc private func handleFlashButtonTap() {
        flashButton.isSelected = !flashButton.isSelected
        onFlashToggle?(flashButton.isSelected)
    }
    
    @objc private func handleToggleCameraButtonTap() {
        onToggleCameraButtonTap?()
    }
    
    @objc private func onPhotoViewTap(_ tapRecognizer: UITapGestureRecognizer) {
        onCloseButtonTap?()
    }
}
