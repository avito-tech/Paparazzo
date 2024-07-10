import ImageSource
import UIKit

final class ScannerView: UIView, ThemeConfigurable {
    
    typealias ThemeType = ScannerRootModuleUITheme
    
    // MARK: - Subviews
    
    private let closeButton = UIButton()
    
    private var cameraView: UIView?
    
    // MARK: - Constants
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    
    private var theme: ThemeType?
    
    // MARK: - Helpers
    
    private var deviceOrientation = DeviceOrientation.portrait
    private let infoMessageDisplayer = InfoMessageDisplayer()
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        addSubview(closeButton)
        
        setUpButtons()
        
        setUpAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutCloseButton()
        
        cameraView?.frame = bounds
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        closeButton.setImage(theme.closeCameraIcon, for: .normal)
        closeButton.tintColor = theme.mediaPickerIconColor
        
        let onePointSize = CGSize(width: 1, height: 1)
        closeButton.setBackgroundImage(
            UIImage.imageWithColor(theme.cameraButtonsBackgroundNormalColor, imageSize: onePointSize),
            for: .normal
        )
        closeButton.setBackgroundImage(
            UIImage.imageWithColor(theme.cameraButtonsBackgroundHighlightedColor, imageSize: onePointSize),
            for: .highlighted
        )
        closeButton.setBackgroundImage(
            UIImage.imageWithColor(theme.cameraButtonsBackgroundDisabledColor, imageSize: onePointSize),
            for: .disabled
        )
    }
    
    // MARK: - ScannerView
    
    var onCloseButtonTap: (() -> ())?
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        
        deviceOrientation = orientation
        
        var orientation = orientation
        if UIDevice.current.userInterfaceIdiom == .phone {
            orientation = .portrait
        }
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
        
        closeButton.transform = transform
    }
    
    func setCameraView(_ view: UIView) {
        cameraView = view
        insertSubview(view, belowSubview: closeButton)
    }
    
    func showInfoMessage(_ message: String, timeout: TimeInterval) {
        if let cameraView = cameraView {
            let viewData = InfoMessageViewData(text: message, timeout: timeout, font: theme?.infoMessageFont)
            infoMessageDisplayer.display(viewData: viewData, in: cameraView)
        }
    }
    
    // MARK: - Private
    
    private func setUpButtons() {
        closeButton.layer.cornerRadius = closeButtonSize.height / 2
        closeButton.layer.masksToBounds = true
        closeButton.size = closeButtonSize
        closeButton.addTarget(
            self,
            action: #selector(onCloseButtonTap(_:)),
            for: .touchUpInside
        )
    }
    
    private func setUpAccessibilityIdentifiers() {
        closeButton.setAccessibilityId(.closeButton)
        accessibilityIdentifier = AccessibilityId.mediaPicker.rawValue
    }
    
    private func layoutCloseButton() {
        
        closeButton.frame = CGRect(
            x: 8,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: closeButton.width,
            height: closeButton.height
        )
    }
    
    @objc private func onCloseButtonTap(_: UIButton) {
        onCloseButtonTap?()
    }
    
}
