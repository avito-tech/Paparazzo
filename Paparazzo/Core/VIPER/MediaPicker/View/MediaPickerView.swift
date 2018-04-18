import ImageSource
import UIKit

final class MediaPickerView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    // MARK: - Subviews
    
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    
    private let closeButton = UIButton()
    private let continueButton = ButtonWithActivity()
    private let photoTitleLabel = UILabel()
    private let flashView = UIView()
    
    private let thumbnailRibbonView: ThumbnailsView
    private let photoPreviewView: PhotoPreviewView
    
    private var closeAndContinueButtonsSwapped = false
    
    // MARK: - Constants
    
    private let cameraAspectRatio = CGFloat(4) / CGFloat(3)
    
    private let bottomPanelMinHeight: CGFloat = {
        let iPhone5ScreenSize = CGSize(width: 320, height: 568)
        return iPhone5ScreenSize.height - iPhone5ScreenSize.width / 0.75
    }()
    
    private let controlsCompactHeight = CGFloat(54) // (iPhone 4 height) - (iPhone 4 width) * 4/3 (photo aspect ratio) = 53,333...
    
    private var controlsExtendedHeight: CGFloat {
        return 80 + paparazzoSafeAreaInsets.bottom
    }
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    private var theme: ThemeType?
    
    // MARK: - Helpers
    
    private var mode = MediaPickerViewMode.camera
    private var deviceOrientation = DeviceOrientation.portrait
    private let infoMessageDisplayer = InfoMessageDisplayer()
    
    private var showsPreview: Bool = true {
        didSet {
            thumbnailRibbonView.isHidden = !showsPreview
        }
    }
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        thumbnailRibbonView = ThumbnailsView()
        photoPreviewView = PhotoPreviewView()
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        flashView.backgroundColor = .white
        flashView.alpha = 0
        
        setUpButtons()
        setUpThumbnailRibbonView()
        
        photoTitleLabel.textColor = .white
        photoTitleLabel.layer.shadowOffset = .zero
        photoTitleLabel.layer.shadowOpacity = 0.5
        photoTitleLabel.layer.shadowRadius = 2
        photoTitleLabel.layer.masksToBounds = false
        photoTitleLabel.alpha = 0
        
        addSubview(photoPreviewView)
        addSubview(flashView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(thumbnailRibbonView)
        addSubview(closeButton)
        addSubview(photoTitleLabel)
        addSubview(continueButton)
        
        setMode(.camera)
        setUpAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: (ayutkin) develop common set of layout rules
        if UIDevice.current.isIPhoneX {
            layOutForIPhoneX()
        } else {
            layOutForDevicesExpectForIPhoneX()
        }
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        cameraControlsView.setTheme(theme)
        photoControlsView.setTheme(theme)
        thumbnailRibbonView.setTheme(theme)
        
        continueButton.setTitleColor(theme.cameraContinueButtonTitleColor, for: .normal)
        continueButton.titleLabel?.font = theme.cameraContinueButtonTitleFont
        
        continueButton.setTitleColor(
            theme.cameraContinueButtonTitleColor,
            for: .normal
        )
        continueButton.setTitleColor(
            theme.cameraContinueButtonTitleHighlightedColor,
            for: .highlighted
        )
        
        let onePointSize = CGSize(width: 1, height: 1)
        for button in [continueButton, closeButton] {
            button.setBackgroundImage(
                UIImage.imageWithColor(theme.cameraButtonsBackgroundNormalColor, imageSize: onePointSize),
                for: .normal
            )
            button.setBackgroundImage(
                UIImage.imageWithColor(theme.cameraButtonsBackgroundHighlightedColor, imageSize: onePointSize),
                for: .highlighted
            )
            button.setBackgroundImage(
                UIImage.imageWithColor(theme.cameraButtonsBackgroundDisabledColor, imageSize: onePointSize),
                for: .disabled
            )
        }
    }
    
    // MARK: - MediaPickerView
    
    var onShutterButtonTap: (() -> ())? {
        get { return cameraControlsView.onShutterButtonTap }
        set { cameraControlsView.onShutterButtonTap = newValue }
    }
    
    var onPhotoLibraryButtonTap: (() -> ())? {
        get { return cameraControlsView.onPhotoLibraryButtonTap }
        set { cameraControlsView.onPhotoLibraryButtonTap = newValue }
    }
    
    var onFlashToggle: ((Bool) -> ())? {
        get { return cameraControlsView.onFlashToggle }
        set { cameraControlsView.onFlashToggle = newValue }
    }
    
    var onItemSelect: ((MediaPickerItem) -> ())?
    
    var onRemoveButtonTap: (() -> ())? {
        get { return photoControlsView.onRemoveButtonTap }
        set { photoControlsView.onRemoveButtonTap = newValue }
    }
    
    var onAutocorrectButtonTap: (() -> ())? {
        get { return photoControlsView.onAutocorrectButtonTap }
        set { photoControlsView.onAutocorrectButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return photoControlsView.onCropButtonTap }
        set { photoControlsView.onCropButtonTap = newValue }
    }
    
    var onCameraThumbnailTap: (() -> ())? {
        get { return photoControlsView.onCameraButtonTap }
        set { photoControlsView.onCameraButtonTap = newValue }
    }
    
    var onItemMove: ((Int, Int) -> ())?
    
    var onSwipeToItem: ((MediaPickerItem) -> ())? {
        get { return photoPreviewView.onSwipeToItem }
        set { photoPreviewView.onSwipeToItem = newValue }
    }
    
    var onSwipeToCamera: (() -> ())? {
        get { return photoPreviewView.onSwipeToCamera }
        set { photoPreviewView.onSwipeToCamera = newValue }
    }
    
    var onSwipeToCameraProgressChange: ((CGFloat) -> ())? {
        get { return photoPreviewView.onSwipeToCameraProgressChange }
        set { photoPreviewView.onSwipeToCameraProgressChange = newValue }
    }
    
    var previewSize: CGSize {
        return photoPreviewView.size
    }
    
    func setMode(_ mode: MediaPickerViewMode) {
        
        switch mode {
        
        case .camera:
            cameraControlsView.isHidden = false
            photoControlsView.isHidden = true
            
            thumbnailRibbonView.selectCameraItem()
            photoPreviewView.scrollToCamera()
        
        case .photoPreview(let photo):
            
            photoPreviewView.scrollToMediaItem(photo)
            
            cameraControlsView.isHidden = true
            photoControlsView.isHidden = false
        }
        
        self.mode = mode
        
        adjustForDeviceOrientation(deviceOrientation)
    }
    
    func setAutocorrectionStatus(_ status: MediaPickerAutocorrectionStatus) {
        switch status {
        case .original:
            photoControlsView.setAutocorrectButtonSelected(false)
        case .corrected:
            photoControlsView.setAutocorrectButtonSelected(true)
        }
    }
    
    func setCameraControlsEnabled(_ enabled: Bool) {
        cameraControlsView.setCameraControlsEnabled(enabled)
    }
    
    func setCameraButtonVisible(_ visible: Bool) {
        photoPreviewView.setCameraVisible(visible)
        thumbnailRibbonView.setCameraItemVisible(visible)
    }
    
    func setHapticFeedbackEnabled(_ enabled: Bool) {
        photoPreviewView.hapticFeedbackEnabled = enabled
        thumbnailRibbonView.setHapticFeedbackEnabled(enabled)
    }
    
    func setLatestPhotoLibraryItemImage(_ image: ImageSource?) {
        cameraControlsView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(_ visible: Bool) {
        cameraControlsView.setFlashButtonVisible(visible)
    }
    
    func setFlashButtonOn(_ isOn: Bool) {
        cameraControlsView.setFlashButtonOn(isOn)
    }
    
    func animateFlash() {
        
        flashView.alpha = 1
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: { 
                self.flashView.alpha = 0
            },
            completion: nil
        )
    }
    
    var onCloseButtonTap: (() -> ())?
    
    var onContinueButtonTap: (() -> ())?
    
    var onCameraToggleButtonTap: (() -> ())? {
        get { return cameraControlsView.onCameraToggleButtonTap }
        set { cameraControlsView.onCameraToggleButtonTap = newValue }
    }
    
    func setCameraToggleButtonVisible(_ visible: Bool) {
        cameraControlsView.setCameraToggleButtonVisible(visible)
    }
    
    func setShutterButtonEnabled(_ enabled: Bool) {
        cameraControlsView.setShutterButtonEnabled(enabled)
    }
    
    func setPhotoLibraryButtonEnabled(_ enabled: Bool) {
        cameraControlsView.setPhotoLibraryButtonEnabled(enabled)
    }
    
    func setPhotoLibraryButtonVisible(_ visible: Bool) {
        cameraControlsView.setPhotoLibraryButtonVisible(visible)
    }
    
    func setContinueButtonVisible(_ visible: Bool) {
        continueButton.isHidden = !visible
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        guard continueButton.style != style else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.continueButton.style = style
                if self.deviceOrientation == .portrait {
                    self.continueButton.size = CGSize(
                        width: self.continueButton.sizeThatFits().width,
                        height: self.continueButtonHeight
                    )
                } else {
                    self.continueButton.size = CGSize(
                        width: self.continueButtonHeight,
                        height: self.continueButton.sizeThatFits().width
                    )
                }
                self.layoutCloseAndContinueButtons()
            }
        )
    }
    
    func addItems(_ items: [MediaPickerItem], animated: Bool, completion: @escaping () -> ()) {
        photoPreviewView.addItems(items)
        thumbnailRibbonView.addItems(items, animated: animated, completion: completion)
    }
    
    func updateItem(_ item: MediaPickerItem) {
        photoPreviewView.updateItem(item)
        thumbnailRibbonView.updateItem(item)
    }

    func removeItem(_ item: MediaPickerItem) {
        photoPreviewView.removeItem(item, animated: false)
        thumbnailRibbonView.removeItem(item, animated: true)
    }
    
    func selectItem(_ item: MediaPickerItem) {
        thumbnailRibbonView.selectMediaItem(item)
    }
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        photoPreviewView.moveItem(from: sourceIndex, to: destinationIndex)
    }
    
    func scrollToItemThumbnail(_ item: MediaPickerItem, animated: Bool) {
        thumbnailRibbonView.scrollToItemThumbnail(item, animated: animated)
    }
    
    func selectCamera() {
        thumbnailRibbonView.selectCameraItem()
    }
    
    func scrollToCameraThumbnail(animated: Bool) {
        thumbnailRibbonView.scrollToCameraThumbnail(animated: animated)
    }
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        
        deviceOrientation = orientation
        
        var orientation = orientation
        if UIDevice.current.userInterfaceIdiom == .phone, case .photoPreview = mode {
            orientation = .portrait
        }
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
        
        closeAndContinueButtonsSwapped = (orientation == .landscapeLeft)
        
        closeButton.transform = transform
        continueButton.transform = transform
        
        cameraControlsView.setControlsTransform(transform)
        photoControlsView.setControlsTransform(transform)
        thumbnailRibbonView.setControlsTransform(transform)
    }
    
    func setCameraView(_ view: UIView) {
        photoPreviewView.setCameraView(view)
    }
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters) {
        thumbnailRibbonView.setCameraOutputParameters(parameters)
    }
    
    func setCameraOutputOrientation(_ orientation: ExifOrientation) {
        thumbnailRibbonView.setCameraOutputOrientation(orientation)
    }
    
    func setPhotoTitle(_ title: String) {
        photoTitleLabel.text = title
        photoTitleLabel.accessibilityValue = title
        layoutPhotoTitleLabel()
    }
    
    func setPreferredPhotoTitleStyle(_ style: MediaPickerTitleStyle) {
        switch style {
        // TODO: (ayutkin) don't allow presenter to set title style directly
        case .light where !UIDevice.current.isIPhoneX:
            photoTitleLabel.textColor = .white
            photoTitleLabel.layer.shadowOpacity = 0.5
        case .dark, .light:
            photoTitleLabel.textColor = .black
            photoTitleLabel.layer.shadowOpacity = 0
        }
    }
    
    func setPhotoTitleAlpha(_ alpha: CGFloat) {
        photoTitleLabel.alpha = alpha
    }
    
    func setCloseButtonImage(_ image: UIImage?) {
        closeButton.setImage(image, for: .normal)
    }
    
    func setContinueButtonTitle(_ title: String) {
        continueButton.setTitle(title, for: .normal)
        continueButton.accessibilityValue = title
        continueButton.size = CGSize(width: continueButton.sizeThatFits().width, height: continueButtonHeight)
    }
    
    func setContinueButtonEnabled(_ enabled: Bool) {
        continueButton.isEnabled = enabled
    }
    
    func setShowsCropButton(_ showsCropButton: Bool) {
        if showsCropButton {
            photoControlsView.mode.insert(.hasCropButton)
        } else {
            photoControlsView.mode.remove(.hasCropButton)
        }
    }
    
    func setShowsAutocorrectButton(_ showsAutocorrectButton: Bool) {
        if showsAutocorrectButton {
            photoControlsView.mode.insert(.hasAutocorrectButton)
        } else {
            photoControlsView.mode.remove(.hasAutocorrectButton)
        }
    }
    
    func setShowsPreview(_ showsPreview: Bool) {
        self.showsPreview = showsPreview
    }
    
    func reloadCamera() {
        photoPreviewView.reloadCamera()
        thumbnailRibbonView.reloadCamera()
    }
    
    func showInfoMessage(_ message: String, timeout: TimeInterval) {
        let viewData = InfoMessageViewData(text: message, timeout: timeout, font: theme?.infoMessageFont)
        infoMessageDisplayer.display(viewData: viewData, in: photoPreviewView)
    }
    
    // MARK: - Private
    
    private func setUpThumbnailRibbonView() {
        
        thumbnailRibbonView.onPhotoItemSelect = { [weak self] mediaPickerItem in
            self?.onItemSelect?(mediaPickerItem)
        }
        
        thumbnailRibbonView.onCameraItemSelect = { [weak self] in
            self?.onCameraThumbnailTap?()
        }
        
        thumbnailRibbonView.onItemMove = { [weak self] sourceIndex, destinationIndex in
            self?.onItemMove?(sourceIndex, destinationIndex)
        }
        
        thumbnailRibbonView.onDragStart = { [weak self] in
            self?.isUserInteractionEnabled = false
        }
        
        thumbnailRibbonView.onDragFinish = { [weak self] in
            self?.isUserInteractionEnabled = true
        }
    }
    
    private func setUpButtons() {
        closeButton.layer.cornerRadius = closeButtonSize.height / 2
        closeButton.layer.masksToBounds = true
        closeButton.size = closeButtonSize
        closeButton.addTarget(
            self,
            action: #selector(onCloseButtonTap(_:)),
            for: .touchUpInside
        )
        
        continueButton.layer.cornerRadius = continueButtonHeight / 2
        continueButton.layer.masksToBounds = true
        continueButton.contentEdgeInsets = continueButtonContentInsets
        continueButton.addTarget(
            self,
            action: #selector(onContinueButtonTap(_:)),
            for: .touchUpInside
        )
    }
    
    private func setUpAccessibilityIdentifiers() {
        closeButton.setAccessibilityId(.closeButton)
        continueButton.setAccessibilityId(.continueButton)
        photoTitleLabel.setAccessibilityId(.titleLabel)
        
        accessibilityIdentifier = AccessibilityId.mediaPicker.rawValue
    }
    
    private func layOutForIPhoneX() {
        
        let controlsHeight = CGFloat(135)
        let thumbnailRibbonHeight = CGFloat(74)
        let thumbnailRibbonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: controlsHeight
        )
        
        photoControlsView.frame = cameraControlsView.frame
        
        thumbnailRibbonView.backgroundColor = UIColor.white
        thumbnailRibbonView.contentInsets = thumbnailRibbonInsets
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: thumbnailRibbonHeight
        )
        
        photoPreviewView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: thumbnailRibbonView.top,
            height: bounds.size.width * cameraAspectRatio
        )
        
        flashView.frame = photoPreviewView.frame
        
        layoutCloseAndContinueButtons()
        layoutPhotoTitleLabel()
    }
    
    private func layOutForDevicesExpectForIPhoneX() {
        
        let cameraFrame = CGRect(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: showsPreview ? bounds.size.width * cameraAspectRatio : bounds.size.height - controlsExtendedHeight
        )
        
        let controlsHeight: CGFloat
        if showsPreview {
            let freeSpaceUnderCamera = bounds.bottom - cameraFrame.bottom
            let canFitExtendedControls = (freeSpaceUnderCamera >= controlsExtendedHeight)
            controlsHeight = canFitExtendedControls ? controlsExtendedHeight : controlsCompactHeight
        } else {
            controlsHeight = controlsExtendedHeight
        }
        
        photoPreviewView.frame = cameraFrame
        
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: controlsHeight
        )
        
        photoControlsView.frame = cameraControlsView.frame
        
        let screenIsVerySmall = (cameraControlsView.top < cameraFrame.bottom)
        
        let thumbnailRibbonAlpha: CGFloat = screenIsVerySmall ? 0.6 : 1
        let thumbnailRibbonInsets = UIEdgeInsets(
            top: 8,
            left: 8,
            bottom: thumbnailRibbonAlpha < 1 ? 8 : 0,
            right: 8
        )
        
        let thumbnailHeightForSmallScreen = CGFloat(56)
        let bottomPanelHeight = max(height - width / 0.75, bottomPanelMinHeight)
        
        let photoRibbonHeight = screenIsVerySmall
            ? thumbnailHeightForSmallScreen + thumbnailRibbonInsets.top + thumbnailRibbonInsets.bottom
            : bottomPanelHeight - controlsHeight
        
        thumbnailRibbonView.backgroundColor = UIColor.white.withAlphaComponent(thumbnailRibbonAlpha)
        thumbnailRibbonView.contentInsets = thumbnailRibbonInsets
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: photoRibbonHeight
        )
        
        layoutCloseAndContinueButtons()
        layoutPhotoTitleLabel()
        
        flashView.frame = cameraFrame
    }
    
    private func layoutCloseAndContinueButtons() {
        
        let leftButton = closeAndContinueButtonsSwapped ? continueButton : closeButton
        let rightButton = closeAndContinueButtonsSwapped ? closeButton : continueButton
        
        leftButton.frame = CGRect(
            x: 8,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: leftButton.width,
            height: leftButton.height
        )
        
        rightButton.frame = CGRect(
            x: bounds.right - 8 - rightButton.width,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: rightButton.width,
            height: rightButton.height
        )
    }
    
    private func layoutPhotoTitleLabel() {
        photoTitleLabel.sizeToFit()
        photoTitleLabel.left = ceil(bounds.centerX - photoTitleLabel.width / 2)
        photoTitleLabel.top = max(8, paparazzoSafeAreaInsets.top) + 9
    }
    
    @objc private func onCloseButtonTap(_: UIButton) {
        onCloseButtonTap?()
    }
    
    @objc private func onContinueButtonTap(_: UIButton) {
        onContinueButtonTap?()
    }
}
