import ImageSource
import UIKit
import AVFoundation

final class CameraView: UIView, CameraViewInput, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    private let accessDeniedView = AccessDeniedView()
    private var cameraOutputView: CameraOutputView?
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hintLabel = UILabel()
    private var outputParameters: CameraOutputParameters?
    private var focusIndicator: FocusIndicator?
    private var theme: ThemeType?
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        accessDeniedView.isHidden = true
        titleLabel.backgroundColor = .clear
        titleLabel.isUserInteractionEnabled = false
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.isUserInteractionEnabled = false
        
        addSubview(accessDeniedView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(hintLabel)
        
        setUpCameraHintLabel()
        setUpAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpAccessibilityIdentifiers() {
        titleLabel.setAccessibilityId(.cameraTitle)
        subtitleLabel.setAccessibilityId(.cameraSubtitle)
        hintLabel.setAccessibilityId(.cameraHint)
        accessibilityIdentifier = AccessibilityId.cameraView.rawValue
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelsTargetCenterY = CGFloat(27)
        
        accessDeniedView.bounds = bounds
        accessDeniedView.center = bounds.center
        
        cameraOutputView?.frame = bounds
        
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        
        titleLabel.centerX = bounds.centerX
        titleLabel.top = floor(labelsTargetCenterY - (titleLabel.height + subtitleLabel.height) / 2)
        
        subtitleLabel.centerX = bounds.centerX
        subtitleLabel.top = titleLabel.bottom
        
        hintLabel.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bottom,
            height: CGFloat(80)
        )
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let screenSize = bounds.size
        guard screenSize.width != 0 && screenSize.height != 0 && accessDeniedView.isHidden == true  else {
            return
        }
        
        if let touchPoint = touches.first?.location(in: self) {
            let focusOriginX = touchPoint.y / screenSize.height
            let focusOriginY = 1.0 - touchPoint.x / screenSize.width
            let focusPoint = CGPoint(x: focusOriginX, y: focusOriginY)
            
            onFocusTap?(focusPoint, touchPoint)
        }
    }
    
    // MARK: - CameraViewInput
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func setSubtitle(_ subtitle: String?) {
        subtitleLabel.text = subtitle
    }
    
    var onFocusTap: ((_ focusPoint: CGPoint, _ touchPoint: CGPoint) -> Void)?
    
    func displayFocus(onPoint focusPoint: CGPoint) {
        focusIndicator?.hide()
        focusIndicator = FocusIndicator()
        if let theme = theme {
            focusIndicator?.setColor(theme.focusIndicatorColor)
        }
        focusIndicator?.animate(in: layer, focusPoint: focusPoint)
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
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
    
    func setOutputParameters(_ parameters: CameraOutputParameters) {
        
        let newCameraOutputView = CameraOutputView(
            captureSession: parameters.captureSession,
            outputOrientation: parameters.orientation
        )
        
        if UIDevice.systemVersionLessThan(version: "9.0"), let currentCameraOutputView = self.cameraOutputView {
            // AI-3326: костыль для iOS 8.
            // Удаляем предыдущую вьюху, как только будет нарисован первый фрейм новой вьюхи, иначе будет мелькание.
            newCameraOutputView.onFrameDraw = { [weak newCameraOutputView] in
                newCameraOutputView?.onFrameDraw = nil
                DispatchQueue.main.async {
                    currentCameraOutputView.removeFromSuperviewAfterFadingOut(withDuration: 0.25)
                }
            }
        } else {
            cameraOutputView?.removeFromSuperview()
        }
        
        addSubview(newCameraOutputView)
        
        bringSubviewToFront(titleLabel)
        bringSubviewToFront(subtitleLabel)
        bringSubviewToFront(hintLabel)
        
        self.cameraOutputView = newCameraOutputView
        self.outputParameters = parameters
    }
    
    func setOutputOrientation(_ orientation: ExifOrientation) {
        outputParameters?.orientation = orientation
        cameraOutputView?.orientation = orientation
    }
    
    func mainModuleDidAppear(animated: Bool) {
        // AI-3326: костыль для iOS 8.
        if UIDevice.systemVersionLessThan(version: "9.0"), let outputParameters = outputParameters {
            setOutputParameters(outputParameters)
        }
    }
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        UIView.animate(withDuration: 0.25) {
            self.accessDeniedView.transform = CGAffineTransform(deviceOrientation: orientation)
        }
    }
    
    func setCameraHint(text: String) {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.05
        style.minimumLineHeight = 24
        style.alignment = NSTextAlignment.center
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: style,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        hintLabel.attributedText = attributedString
        hintLabel.isHidden = false
    }
    
    func setCameraHintVisible(_ visible: Bool) {
        let alpha = visible ? CGFloat(1) : CGFloat(0)
        UIView.animate(withDuration: 0.3) {
            self.hintLabel.alpha = alpha
        }
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        accessDeniedView.setTheme(theme)
        focusIndicator?.setColor(theme.focusIndicatorColor)
        titleLabel.textColor = theme.cameraTitleColor
        titleLabel.font = theme.cameraTitleFont
        subtitleLabel.textColor = theme.cameraSubtitleColor
        subtitleLabel.font = theme.cameraSubtitleFont
        hintLabel.font = theme.cameraHintFont
        hintLabel.textColor = theme.cameraTitleColor
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(_ object: AnyObject) {
        disposables.append(object)
    }
    
    private func setUpCameraHintLabel() {
        hintLabel.backgroundColor = .clear
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .center
        hintLabel.isHidden = true
    }
}
