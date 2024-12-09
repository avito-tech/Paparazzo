import UIKit
import AVFoundation

final class CameraV3View: UIView {
    struct Spec {
        static let topButtonsSize = CGSize(width: 38, height: 38)
        static let topButtonInsets = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 8)
        static let shutterButtonBottomOffset: CGFloat = 16
        static let cameraOutputViewIPadBottomOffset: CGFloat = 118
        static let selectedPhotosViewIPadXOffset: CGFloat = 48
        static let hintDefaultHeight: CGFloat = 65
        static let closeButtonDefaultTopOffset: CGFloat = {
            UIDevice.current.userInterfaceIdiom == .phone ? 20 : 24
        }()
    }
    
    var cameraOutputLayer: AVCaptureVideoPreviewLayer?
    private let closeButton = UIButton()
    private let flashButton = UIButton()
    private let toggleButton = UIButton()
    private let hintView = CameraHintView()
    private let cameraOutputView = UIView()
    private let bottomView = UIView()
    private let gridView = GridView(isCenterSquare: true)
    private let flashView = UIView()
    private let shutterButton = ShutterButton()
    private let accessDeniedView = AccessDeniedView()
    private let selectedPhotosView = SelectedPhotosView()
    private var focusIndicator: FocusIndicatorV3?
    private var theme: CameraV3UITheme?
    
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
    var onFocusTap: ((_ focusPoint: CGPoint, _ touchPoint: CGPoint) -> Void)?
    
    var onDrawingMeasurementStop: (() -> ())?
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        
        addSubview(closeButton)
        addSubview(flashButton)
        addSubview(toggleButton)
        addSubview(shutterButton)
        addSubview(cameraOutputView)
        addSubview(gridView)
        addSubview(hintView)
        addSubview(bottomView)
        addSubview(selectedPhotosView)
        addSubview(accessDeniedView)
        addSubview(flashView)
        
        flashView.alpha = 0
        accessDeniedView.isHidden = true
        cameraOutputView.backgroundColor = .black
        cameraOutputView.layer.masksToBounds = true
        
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(flashButtonDidTap), for: .touchUpInside)
        toggleButton.addTarget(self, action: #selector(toggleButtonDidTap), for: .touchUpInside)
        
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
            x: toggleButton.left - Spec.topButtonsSize.width,
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
        
        let hintHeight = max((cameraOutputView.height - cameraOutputView.width) / 2, Spec.hintDefaultHeight)
        
        hintView.frame = CGRect(
            left: left,
            right: right,
            top: cameraOutputView.top,
            height: hintHeight
        )
        
        bottomView.frame = CGRect(
            left: left,
            right: right,
            bottom: cameraOutputView.bottom,
            height: hintHeight
        )
        
        gridView.frame = CGRect(
            centerX: cameraOutputView.centerX,
            centerY: cameraOutputView.centerY,
            width: cameraOutputView.width,
            height: cameraOutputView.height
        )
        
        cameraOutputLayer?.frame.size = cameraOutputView.size
        accessDeniedView.frame = cameraOutputView.frame
        flashView.frame = cameraOutputView.frame
        
        let selectedPhotosViewX: CGFloat
        let shutterButtonRightX = shutterButton.centerX + shutterButton.width / 2
        let selectedPhotosViewSize = selectedPhotosView.sizeThatFits(size)
        if UIDevice.current.userInterfaceIdiom == .phone {
            selectedPhotosViewX = shutterButtonRightX + (self.right - shutterButtonRightX - selectedPhotosViewSize.width) / 2
        } else  {
            selectedPhotosViewX = shutterButtonRightX + Spec.selectedPhotosViewIPadXOffset
        }
        
        selectedPhotosView.frame = CGRect(
            x: selectedPhotosViewX,
            y: shutterButton.centerY - selectedPhotosViewSize.height / 2,
            width: selectedPhotosViewSize.width,
            height: selectedPhotosViewSize.height
        )
    }
    
    // MARK: - Theme
    func setTheme(_ theme: CameraV3UITheme) {
        self.theme = theme
        
        backgroundColor = theme.cameraV3ViewBackground
        flashView.backgroundColor = backgroundColor
        
        closeButton.tintColor = theme.cameraV3CloseIconColor
        closeButton.setImage(theme.cameraV3CloseIcon, for: .normal)
        flashButton.tintColor = theme.cameraV3FlashIconColor
        flashButton.setImage(theme.cameraV3FlashOffIcon, for: .normal)
        flashButton.setImage(theme.cameraV3FlashOnIcon, for: .selected)
        toggleButton.tintColor = theme.cameraV3ToggleCameraIconColor
        toggleButton.setImage(theme.cameraV3ToggleCameraIcon, for: .normal)
        
        shutterButton.setTheme(ShutterButton.Theme(
            scaleFactor: theme.cameraV3ShutterScaleFactor,
            enabledColor: theme.cameraV3ShutterEnabledColor,
            disabledColor: theme.cameraV3ShutterDisabledColor
        ))
        
        selectedPhotosView.setTheme(theme)
        accessDeniedView.setThemeV3(theme)
        
        hintView.label.font = theme.cameraV3HintViewFont
        hintView.label.textColor = theme.cameraV3HintViewFontColor
        hintView.backgroundColor = theme.cameraV3HintViewBackground
        bottomView.backgroundColor = theme.cameraV3HintViewBackground
    }
    
    // MARK: - CameraV3View
    func setShutterButtonEnabled(_ flag: Bool, animated: Bool) {
        shutterButton.setState(flag ? .enabled : .disabled, animated: animated)
    }
    
    func setHintText(_ text: String) {
        hintView.label.text = text
    }
    
    func setSelectedData(_ viewData: SelectedPhotosViewData?, animated: Bool) {
        selectedPhotosView.setViewData(viewData, animated: animated)
    }
    
    func setSelectedDataEnabled(_ flag: Bool) {
        selectedPhotosView.isUserInteractionEnabled = flag
    }
    
    func showFocus(on point: CGPoint) {
        focusIndicator?.hide()
        focusIndicator = FocusIndicatorV3()
        if let theme = theme {
            focusIndicator?.setTheme(theme)
        }
        focusIndicator?.show(in: cameraOutputView.layer, focusPoint: point)
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
        
        DispatchQueue.main.async { [weak self] in
            self?.onDrawingMeasurementStop?()
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let screenSize = bounds.size
        if screenSize == .zero && !accessDeniedView.isHidden {
            return
        }
    
        if let touchPoint = touches.first?.location(in: cameraOutputView) {
            let focusOriginX = touchPoint.y / screenSize.height
            let focusOriginY = 1.0 - touchPoint.x / screenSize.width
            let focusPoint = CGPoint(x: focusOriginX, y: focusOriginY)

            onFocusTap?(focusPoint, touchPoint)
        }
    }
}

fileprivate final class CameraHintView: UIView {
    struct Spec {
        static let horizontalInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
    }
    
    let label = UILabel()
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.setAccessibilityId(.cameraHint)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        let availableSize = label.sizeForWidth(bounds.width - Spec.horizontalInsets.left - Spec.horizontalInsets.right)

        label.frame = CGRect(
            centerX: bounds.centerX,
            centerY: bounds.centerY,
            width: availableSize.width,
            height: availableSize.height
        )
    }
}
