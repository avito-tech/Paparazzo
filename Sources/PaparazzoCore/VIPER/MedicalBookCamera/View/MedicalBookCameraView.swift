import AVFoundation
import UIKit

final class MedicalBookCameraView: UIView {
    private let closeButton = UIButton()
    private let flashButton = UIButton()
    private let toggleButton = UIButton()
    
    private let cameraOutputView = UIView()
    private let flashView = UIView()
    
    private let hintView = MedicalCameraHintView()
    private let shutterButton = ShutterButton()
    private let accessDeniedView = AccessDeniedView()
    private let selectedPhotosView = SelectedPhotosView()
    private let doneButton = UIButton()
    
    private let maskOverlayView = MedicalMaskOverlayView()
    
    var cameraOutputLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Handlers
    var onShutterButtonTap: (() -> ())? {
        get { shutterButton.onTap }
        set { shutterButton.onTap = newValue }
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { selectedPhotosView.onTap }
        set { selectedPhotosView.onTap = newValue }
    }
    
    var onCloseButtonTap: (() -> ())?
    var onToggleCameraButtonTap: (() -> ())?
    var onFlashToggle: ((Bool) -> ())?
    var onDoneButtonTap: (() -> ())?
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        addSubview(closeButton)
        addSubview(flashButton)
        addSubview(toggleButton)
        addSubview(shutterButton)
        addSubview(cameraOutputView)
        addSubview(maskOverlayView)
        addSubview(hintView)
        addSubview(selectedPhotosView)
        addSubview(doneButton)
        addSubview(accessDeniedView)
        addSubview(flashView)
        
        flashView.alpha = 0
        maskOverlayView.backgroundColor = .clear
        accessDeniedView.isHidden = true
        cameraOutputView.backgroundColor = .black
        cameraOutputView.layer.masksToBounds = true
        
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(flashButtonDidTap), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(toggleButtonDidTap), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
        
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAccessibilityIds() {
        selectedPhotosView.setAccessibilityId(.cameraThumbnailCell)
        closeButton.setAccessibilityId(.closeButton)
        flashButton.setAccessibilityId(.flashButton)
        toggleButton.setAccessibilityId(.cameraToggleButton)
        cameraOutputView.setAccessibilityId(.cameraViewfinder)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let paparazzoSafeAreaInsets = window?.paparazzoSafeAreaInsets ?? paparazzoSafeAreaInsets
        
        closeButton.frame = CGRect(
            x: bounds.left + Spec.topButtonInsets.left,
            y: max(Spec.closeButtonDefaultTopOffset, paparazzoSafeAreaInsets.top),
            width: Spec.topButtonsSize.width,
            height: Spec.topButtonsSize.height
        )
        
        toggleButton.frame = CGRect(
            x: bounds.right - Spec.topButtonsSize.width - Spec.topButtonInsets.right,
            y: closeButton.y,
            width: Spec.topButtonsSize.width,
            height: Spec.topButtonsSize.height
        )
        
        flashButton.frame = CGRect(
            x: toggleButton.left - Spec.topButtonsSize.width - Spec.topButtonInsets.right,
            y: closeButton.y,
            width: Spec.topButtonsSize.width,
            height: Spec.topButtonsSize.height
        )
        
        let shutterButtonSize = shutterButton.sizeThatFits(size)
        
        let centerYTakePhoto = bottom
            - (shutterButtonSize.height / 2)
            - paparazzoSafeAreaInsets.bottom
            - Spec.shutterButtonBottomOffset
        
        shutterButton.frame = CGRect(
            centerX: centerX,
            centerY: centerYTakePhoto,
            width: shutterButtonSize.width,
            height: shutterButtonSize.height
        )
        
        let height: CGFloat
        if UIDevice.current.userInterfaceIdiom == .phone {
            height = bounds.width / 3 * 4
        } else  {
            height = bounds.height
            - paparazzoSafeAreaInsets.bottom
            - Spec.cameraOutputViewIPadBottomOffset
            - closeButton.bottom
            + Spec.topButtonInsets.top
        }
        
        cameraOutputView.frame = CGRect(
            left: left,
            right: right,
            top: closeButton.bottom + Spec.topButtonInsets.top,
            height: height
        )
        
        hintView.frame = CGRect(
            left: left,
            right: right,
            top: cameraOutputView.bottom + 3,
            height: Spec.hintDefaultHeight
        )
        
        maskOverlayView.frame = CGRect(
            centerX: cameraOutputView.centerX,
            centerY: cameraOutputView.centerY,
            width: cameraOutputView.width,
            height: cameraOutputView.height
        )
        
        cameraOutputLayer?.frame.size = cameraOutputView.size
        accessDeniedView.frame = cameraOutputView.frame
        flashView.frame = cameraOutputView.frame
        
        let selectedPhotosLeftViewX: CGFloat
        let doneButtonRightViewX: CGFloat
        
        let shutterButtonLeftX = shutterButton.centerX - shutterButton.width / 2
        let doneButtonLeRightX = shutterButton.centerX + shutterButton.width / 2
        
        let selectedPhotosViewSize = selectedPhotosView.sizeThatFits(size)
        let doneButtonViewSize = Spec.doneButtonSize
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            selectedPhotosLeftViewX = shutterButtonLeftX + (self.left - shutterButtonLeftX - selectedPhotosViewSize.width) / 2
            doneButtonRightViewX = doneButtonLeRightX + (self.right - doneButtonLeRightX - doneButtonViewSize.width) / 2
        } else  {
            selectedPhotosLeftViewX = shutterButtonLeftX + Spec.selectedPhotosViewIPadXOffset
            doneButtonRightViewX = doneButtonLeRightX + Spec.selectedPhotosViewIPadXOffset
        }
        
        selectedPhotosView.frame = CGRect(
            x: selectedPhotosLeftViewX,
            y: shutterButton.centerY - selectedPhotosViewSize.height / 2,
            width: selectedPhotosViewSize.width,
            height: selectedPhotosViewSize.height
        )
        
        doneButton.frame = CGRect(
            x: doneButtonRightViewX,
            y: shutterButton.centerY - doneButtonViewSize.height / 2,
            width: doneButtonViewSize.width,
            height: doneButtonViewSize.height
        )
    }
    
    // MARK: - Theme
    func setTheme(_ theme: MedicalBookCameraUITheme) {
        backgroundColor = theme.medicalBookViewBackground
        
        flashView.backgroundColor = backgroundColor
        
        closeButton.tintColor = theme.medicalBookCloseIconColor
        closeButton.setImage(theme.medicalBookCloseIcon, for: .normal)
        flashButton.tintColor = theme.medicalBookFlashIconColor
        flashButton.setImage(theme.medicalBookFlashOffIcon, for: .normal)
        flashButton.setImage(theme.medicalBookFlashOnIcon, for: .selected)
        toggleButton.tintColor = theme.medicalBookToggleCameraIconColor
        toggleButton.setImage(theme.medicalBookToggleCameraIcon, for: .normal)
        
        doneButton.titleLabel?.font = theme.medicalBookDoneButtonFont
        doneButton.backgroundColor = theme.medicalBookDoneButtonBackground
        doneButton.contentEdgeInsets = Spec.doneButtonInsets
        doneButton.layer.cornerRadius = Spec.doneButtonCornerRadius
        doneButton.layer.masksToBounds = true
        
        hintView.setTheme(theme)
        
        shutterButton.setTheme(ShutterButton.Theme(
            scaleFactor: theme.medicalBookShutterScaleFactor,
            enabledColor: theme.medicalBookShutterEnabledColor,
            disabledColor: theme.medicalBookShutterDisabledColor
        ))
        
        selectedPhotosView.setTheme(theme)
        accessDeniedView.setThemeMedicalBook(theme)
    }
    
    // MARK: - MedicalBookCameraView
    func setShutterButtonEnabled(_ flag: Bool, animated: Bool) {
        shutterButton.setState(flag ? .enabled : .disabled, animated: animated)
    }
    
    func setHintText(_ text: String) {
        hintView.isHidden = text.isEmpty
        hintView.setLabelText(text)
    }
    
    func setDoneButtonTitle(_ title: String) {
        doneButton.setTitle(title, for: .normal)
    }
    
    func setDoneButtonVisible(_ flag: Bool) {
        doneButton.isHidden = !flag
    }
    
    func setSelectedData(_ viewData: SelectedPhotosViewData?, animated: Bool) {
        selectedPhotosView.setViewData(viewData, animated: animated)
    }
    
    func setSelectedDataEnabled(_ flag: Bool) {
        selectedPhotosView.isUserInteractionEnabled = flag
    }
    
    func animateShot() {
        flashView.alpha = 1
        UIView.animate(withDuration: 0.3) {
            self.flashView.alpha = 0
        }
    }
    
    func setFlashButtonVisible(_ flag: Bool) {
        flashButton.isHidden = !flag
    }
    
    func setFlashButtonOn(_ flag: Bool) {
        flashButton.isSelected = flag
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        self.cameraOutputLayer = previewLayer
        if let previewLayer = previewLayer {
            cameraOutputView.layer.insertSublayer(previewLayer, at: 0)
        }
        setNeedsLayout()
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
    
    func rotateButtons(nextTransform: CGAffineTransform) {
        UIView.animate(withDuration: 0.2) {
            self.closeButton.transform = nextTransform
            self.flashButton.transform = nextTransform
            self.toggleButton.transform = nextTransform
            self.doneButton.transform = nextTransform
            self.selectedPhotosView.transform = nextTransform
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonDidTap() {
        onCloseButtonTap?()
    }
    
    @objc private func flashButtonDidTap() {
        flashButton.isSelected.toggle()
        onFlashToggle?(flashButton.isSelected)
    }
    
    @objc private func toggleButtonDidTap() {
        onToggleCameraButtonTap?()
    }
    
    @objc private func doneButtonDidTap() {
        onDoneButtonTap?()
    }
}

private enum Spec {
    static let topButtonsSize = CGSize(width: 24, height: 24)
    static let topButtonInsets = UIEdgeInsets(top: 12, left: 14, bottom: 0, right: 16)
    static let shutterButtonBottomOffset: CGFloat = 4
    static let cameraOutputViewIPadBottomOffset: CGFloat = 118
    static let selectedPhotosViewIPadXOffset: CGFloat = 48
    static let hintDefaultHeight: CGFloat = 74
    static let doneButtonInsets = UIEdgeInsets(top: 11, left: 16, bottom: 13, right: 16)
    static let doneButtonCornerRadius: CGFloat = 12.0
    static let doneButtonSize = CGSize(width: 83, height: 44)
    static let closeButtonDefaultTopOffset: CGFloat = {
        UIDevice.current.userInterfaceIdiom == .phone ? 20 : 24
    }()
}
