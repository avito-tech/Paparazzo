import ImageSource
import UIKit

final class MediaPickerView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    // MARK: - Subviews
    private let notchMaskingView = UIView()
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    
    private let closeButton = UIButton()
    private let topRightContinueButton = ButtonWithActivity()
    private let bottomContinueButton = UIButton()
    private let photoTitleLabel = UILabel()
    private let flashView = UIView()
    
    private let thumbnailRibbonView: ThumbnailsView
    private let photoPreviewView: PhotoPreviewView
    
    private var closeAndContinueButtonsSwapped = false
    
    // MARK: - Layout constants
    private let topRightContinueButtonHeight = CGFloat(38)
    private let topRightContinueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let fakeNavigationBarMinimumYOffset = CGFloat(20)
    private let fakeNavigationBarContentTopInset = CGFloat(8)
    
    // MARK: - MediaPickerTitleStyle
    private var photoTitleLabelLightTextColor = UIColor.white
    private var photoTitleLabelDarkTextColor = UIColor.black
    
    // MARK: - State
    private var theme: ThemeType?
    
    // MARK: - Helpers
    private var mode = MediaPickerViewMode.camera
    private var deviceOrientation = DeviceOrientation.portrait
    private let infoMessageDisplayer = InfoMessageDisplayer()
    
    private var continueButtonPlacement = MediaPickerContinueButtonPlacement.topRight {
        didSet {
            switch continueButtonPlacement {
            case .topRight:
                bottomContinueButton.removeFromSuperview()
                addSubview(topRightContinueButton)
            case .bottom:
                topRightContinueButton.removeFromSuperview()
                addSubview(bottomContinueButton)
            }
        }
    }
    
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
        
        notchMaskingView.backgroundColor = .black
        
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
        
        addSubview(notchMaskingView)
        addSubview(photoPreviewView)
        addSubview(flashView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(thumbnailRibbonView)
        addSubview(closeButton)
        addSubview(photoTitleLabel)
        addSubview(topRightContinueButton)
        
        setMode(.camera)
        setUpAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cameraAspectRatio = CGFloat(4) / 3
        
        layOutNotchMaskingView()
        layOutFakeNavigationBarButtons()
        layOutBottomContinueButton()
        
        let controlsIdealFrame = CGRect(
            left: bounds.left,
            right: bounds.right,
            bottom: (continueButtonPlacement == .bottom)
                ? bottomContinueButton.top
                : bounds.bottom - paparazzoSafeAreaInsets.bottom,
            height: 93
        )
        
        /// Ideal height of photoPreviewView is when it's aspect ratio is 4:3 (same as camera output)
        let previewIdealHeight = bounds.width * cameraAspectRatio
        let previewIdealBottom = notchMaskingView.bottom + previewIdealHeight
        let thumbnailRibbonUnderPreviewHeight = max(controlsIdealFrame.top - previewIdealBottom, 74)
        let previewTargetHeight = controlsIdealFrame.top - thumbnailRibbonUnderPreviewHeight - notchMaskingView.bottom
        let isIPhone = (UIDevice.current.userInterfaceIdiom == .phone)
        
        // If we are going to shrink preview area so that less than 80% of the ideal height is visible (iPhone 4 case),
        // then we'd rather lay out thumbnail ribbon at the bottom of the preview area
        // and shrink controls height as well.
        if previewTargetHeight / previewIdealHeight < 0.8 && isIPhone {
            layOutMainAreaWithThumbnailRibbonOverlappingPreview()
        } else {
            layOutMainAreaWithThumbnailRibbonUnderPreview(
                controlsFrame: controlsIdealFrame,
                thumbnailRibbonHeight: thumbnailRibbonUnderPreviewHeight
            )
        }
        
        // Flash view
        //
        flashView.frame = photoPreviewView.frame
    }
    
    private func layOutNotchMaskingView() {
        let height = UIDevice.current.hasNotch ? paparazzoSafeAreaInsets.top : 0
        notchMaskingView.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: height
        )
    }
    
    private func layOutFakeNavigationBarButtons() {
        let leftButton = closeAndContinueButtonsSwapped ? topRightContinueButton : closeButton
        let rightButton = closeAndContinueButtonsSwapped ? closeButton : topRightContinueButton
        
        leftButton.frame = CGRect(
            x: bounds.left + 8,
            y: max(notchMaskingView.bottom, fakeNavigationBarMinimumYOffset) + fakeNavigationBarContentTopInset,
            width: leftButton.width,
            height: leftButton.height
        )
        
        rightButton.frame = CGRect(
            x: bounds.right - 8 - rightButton.width,
            y: max(notchMaskingView.bottom, fakeNavigationBarMinimumYOffset) + fakeNavigationBarContentTopInset,
            width: rightButton.width,
            height: rightButton.height
        )
    }
    
    private func layOutBottomContinueButton() {
        bottomContinueButton.layout(
            left: bounds.left + 16,
            right: bounds.right - 16,
            bottom: bounds.bottom - max(14, paparazzoSafeAreaInsets.bottom),
            height: 36
        )
    }
    
    private func layOutMainAreaWithThumbnailRibbonOverlappingPreview() {
        
        let hasBottomContinueButton = (continueButtonPlacement == .bottom)
        
        // Controls
        //
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: hasBottomContinueButton
                ? bottomContinueButton.top - 8
                : bounds.bottom - paparazzoSafeAreaInsets.bottom,
            height: 54
        )
        photoControlsView.frame = cameraControlsView.frame
        
        let previewTargetBottom = cameraControlsView.top - (hasBottomContinueButton ? 8 : 0)
        
        // Thumbnail ribbon
        //
        thumbnailRibbonView.backgroundColor = theme?.thumbnailsViewBackgroundColor.withAlphaComponent(0.6)
        thumbnailRibbonView.contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: previewTargetBottom,
            height: 72
        )
        
        // Camera stream / photo preview area
        //
        photoPreviewView.layout(
            left: bounds.left,
            right: bounds.right,
            top: notchMaskingView.bottom,
            bottom: previewTargetBottom
        )
    }
    
    private func layOutMainAreaWithThumbnailRibbonUnderPreview(
        controlsFrame: CGRect,
        thumbnailRibbonHeight: CGFloat)
    {
        // Controls
        //
        cameraControlsView.frame = controlsFrame
        photoControlsView.frame = controlsFrame
        
        // Thumbnail ribbon
        //
        thumbnailRibbonView.backgroundColor = theme?.thumbnailsViewBackgroundColor
        thumbnailRibbonView.contentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: thumbnailRibbonHeight
        )
        
        // Camera stream / photo preview area
        //
        photoPreviewView.layout(
            left: bounds.left,
            right: bounds.right,
            top: notchMaskingView.bottom,
            bottom: thumbnailRibbonView.top
        )
    }
    
    private func layOutPhotoTitleLabel() {
        photoTitleLabel.sizeToFit()
        photoTitleLabel.left = ceil(bounds.centerX - photoTitleLabel.width / 2)
        photoTitleLabel.top = max(notchMaskingView.bottom, fakeNavigationBarMinimumYOffset) + fakeNavigationBarContentTopInset + 9
    }
    
    // MARK: - ThemeConfigurable
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        backgroundColor = theme.mediaPickerBackgroundColor
        photoPreviewView.backgroundColor = theme.photoPreviewBackgroundColor
        photoPreviewView.collectionViewBackgroundColor = theme.photoPreviewCollectionBackgroundColor
        
        photoTitleLabelLightTextColor = theme.mediaPickerTitleLightColor
        photoTitleLabelDarkTextColor = theme.mediaPickerTitleDarkColor
        
        cameraControlsView.setTheme(theme)
        photoControlsView.setTheme(theme)
        thumbnailRibbonView.setTheme(theme)
        
        topRightContinueButton.setTitleColor(theme.cameraContinueButtonTitleColor, for: .normal)
        topRightContinueButton.titleLabel?.font = theme.cameraContinueButtonTitleFont
        
        topRightContinueButton.setTitleColor(
            theme.cameraContinueButtonTitleColor,
            for: .normal
        )
        topRightContinueButton.setTitleColor(
            theme.cameraContinueButtonTitleHighlightedColor,
            for: .highlighted
        )
        
        let onePointSize = CGSize(width: 1, height: 1)
        for button in [topRightContinueButton, closeButton] {
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
        
        bottomContinueButton.backgroundColor = theme.cameraBottomContinueButtonBackgroundColor
        bottomContinueButton.titleLabel?.font = theme.cameraBottomContinueButtonFont
        bottomContinueButton.setTitleColor(theme.cameraBottomContinueButtonTitleColor, for: .normal)
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
    
    func setContinueButtonVisible(_ isVisible: Bool) {
        topRightContinueButton.isHidden = !isVisible
        bottomContinueButton.isHidden = !isVisible
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        guard topRightContinueButton.style != style else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.topRightContinueButton.style = style
                if self.deviceOrientation == .portrait {
                    self.topRightContinueButton.size = CGSize(
                        width: self.topRightContinueButton.sizeThatFits().width,
                        height: self.topRightContinueButtonHeight
                    )
                } else {
                    self.topRightContinueButton.size = CGSize(
                        width: self.topRightContinueButtonHeight,
                        height: self.topRightContinueButton.sizeThatFits().width
                    )
                }
                self.layOutFakeNavigationBarButtons()
            }
        )
    }
    
    func setContinueButtonPlacement(_ placement: MediaPickerContinueButtonPlacement) {
        continueButtonPlacement = placement
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
        topRightContinueButton.transform = transform
        
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
        layOutPhotoTitleLabel()
    }
    
    func setPreferredPhotoTitleStyle(_ style: MediaPickerTitleStyle) {
        switch style {
        // TODO: (ayutkin) don't allow presenter to set title style directly
        case .light where !UIDevice.current.hasTopSafeAreaInset:
            photoTitleLabel.textColor = photoTitleLabelLightTextColor
            photoTitleLabel.layer.shadowOpacity = 0.5
        case .dark, .light:
            photoTitleLabel.textColor = photoTitleLabelDarkTextColor
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
        topRightContinueButton.setTitle(title, for: .normal)
        topRightContinueButton.accessibilityValue = title
        topRightContinueButton.size = CGSize(width: topRightContinueButton.sizeThatFits().width, height: topRightContinueButtonHeight)
        
        bottomContinueButton.setTitle(title, for: .normal)
        bottomContinueButton.accessibilityValue = title
    }
    
    func setContinueButtonEnabled(_ isEnabled: Bool) {
        topRightContinueButton.isEnabled = isEnabled
        bottomContinueButton.isEnabled = isEnabled
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
    
    func setViewfinderOverlay(_ overlay: UIView?) {
        photoPreviewView.setViewfinderOverlay(overlay)
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
        let closeButtonSize = CGSize(width: 38, height: 38)
        
        closeButton.layer.cornerRadius = closeButtonSize.height / 2
        closeButton.layer.masksToBounds = true
        closeButton.size = closeButtonSize
        closeButton.addTarget(
            self,
            action: #selector(onCloseButtonTap(_:)),
            for: .touchUpInside
        )
        
        topRightContinueButton.layer.cornerRadius = topRightContinueButtonHeight / 2
        topRightContinueButton.layer.masksToBounds = true
        topRightContinueButton.contentEdgeInsets = topRightContinueButtonContentInsets
        topRightContinueButton.addTarget(
            self,
            action: #selector(onContinueButtonTap(_:)),
            for: .touchUpInside
        )
        
        bottomContinueButton.layer.cornerRadius = 5
        bottomContinueButton.titleEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 8, right: 16)
        bottomContinueButton.addTarget(
            self,
            action: #selector(onContinueButtonTap(_:)),
            for: .touchUpInside
        )
    }
    
    private func setUpAccessibilityIdentifiers() {
        closeButton.setAccessibilityId(.closeButton)
        topRightContinueButton.setAccessibilityId(.continueButton)
        bottomContinueButton.setAccessibilityId(.continueButton)
        photoTitleLabel.setAccessibilityId(.titleLabel)
        
        accessibilityIdentifier = AccessibilityId.mediaPicker.rawValue
    }
    
    @objc private func onCloseButtonTap(_: UIButton) {
        onCloseButtonTap?()
    }
    
    @objc private func onContinueButtonTap(_: UIButton) {
        onContinueButtonTap?()
    }
}
