import ImageSource
import UIKit

final class MediaPickerView: UIView, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
    
    var isRedesignedMediaPickerEnabled: Bool = false {
        didSet {
            thumbnailRibbonView.isRedesignedMediaPickerEnabled = isRedesignedMediaPickerEnabled
        }
    }
    
    // MARK: - Subviews
    private let notchMaskingView = UIView()
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    private var imagePerceptionBadgeView = ImagePerceptionBadgeView()
    
    private let closeButton = UIButton()
    private let topRightContinueButton = ButtonWithActivity()
    private let bottomContinueButtonContainer = UIView()
    private let bottomContinueButtonContainerShapeLayer = CAShapeLayer()
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
                bottomContinueButtonContainer.removeFromSuperview()
                addSubview(topRightContinueButton)
            case .bottom:
                topRightContinueButton.removeFromSuperview()
                if isRedesignedMediaPickerEnabled { addSubview(bottomContinueButtonContainer) }
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
        
        if !isRedesignedMediaPickerEnabled {
            backgroundColor = .white
            notchMaskingView.backgroundColor = .black
            photoTitleLabel.textColor = .white
        }

        flashView.backgroundColor = .white
        flashView.alpha = 0
        
        setUpButtons()
        setUpThumbnailRibbonView()
        
        photoTitleLabel.layer.shadowOffset = .zero
        photoTitleLabel.layer.shadowOpacity = 0.5
        photoTitleLabel.layer.shadowRadius = 2
        photoTitleLabel.layer.masksToBounds = false
        photoTitleLabel.alpha = 0
        
        bottomContinueButtonContainerShapeLayer.shadowOffset = CGSize(width: 0, height: -4)
        bottomContinueButtonContainerShapeLayer.shadowOpacity = 0.1
        bottomContinueButtonContainer.layer.insertSublayer(bottomContinueButtonContainerShapeLayer, at: 0)
        
        addSubview(notchMaskingView)
        addSubview(photoPreviewView)
        addSubview(flashView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(thumbnailRibbonView)
        addSubview(closeButton)
        addSubview(photoTitleLabel)
        addSubview(topRightContinueButton)
        addSubview(imagePerceptionBadgeView)
        
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
        layOutBottomContinueViews()
        layoutBadgeView()
        
        let bottomPadding = isRedesignedMediaPickerEnabled
            ? Spec.CameraControlsView.newInsets.bottom
            : Spec.CameraControlsView.legacyInsets.bottom
        let height = isRedesignedMediaPickerEnabled
            ? Spec.CameraControlsView.newHeight
            : Spec.CameraControlsView.legacyHeight
        let controlsIdealFrame = CGRect(
            left: bounds.left,
            right: bounds.right,
            bottom: (continueButtonPlacement == .bottom)
                ? bottomContinueButton.top - bottomPadding
                : bounds.bottom - paparazzoSafeAreaInsets.bottom,
            height: height
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
    
    private func layOutBottomContinueViews() {
        layOutBottomContinueButtonContainer()
        layOutBottomContinueButtonContainerShapeLayer()
        layOutBottomContinueButton()
    }
    
    private func layOutBottomContinueButtonContainer() {
        let height = paparazzoSafeAreaInsets.bottom
            + Spec.BottomContinueButton.newHeight
            + Spec.BottomContinueButton.newInsets.bottom
        bottomContinueButtonContainer.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: height
        )
    }
    
    private func layOutBottomContinueButton() {
        if isRedesignedMediaPickerEnabled {
            bottomContinueButton.layout(
                left: bottomContinueButtonContainer.left + Spec.BottomContinueButton.newInsets.left,
                right: bottomContinueButtonContainer.right - Spec.BottomContinueButton.newInsets.left,
                top: bottomContinueButtonContainer.top + Spec.BottomContinueButton.newInsets.left,
                height: Spec.BottomContinueButton.newHeight
            )
        } else {
            bottomContinueButton.layout(
                left: bounds.left + Spec.BottomContinueButton.legacyInsets.left,
                right: bounds.right - Spec.BottomContinueButton.legacyInsets.right,
                bottom: bounds.bottom - max(Spec.BottomContinueButton.legacyInsets.bottom, paparazzoSafeAreaInsets.bottom),
                height: Spec.BottomContinueButton.legacyHeight
            )
        }
    }
    
    private func layOutBottomContinueButtonContainerShapeLayer() {
        bottomContinueButtonContainerShapeLayer.path = UIBezierPath(
            roundedRect: bottomContinueButtonContainer.bounds,
            cornerRadius: Spec.bottomContinueButtonContainerShapeLayer.cornerRadius
        ).cgPath
        bottomContinueButtonContainerShapeLayer.shadowPath = bottomContinueButtonContainerShapeLayer.path
    }
    
    private func layOutMainAreaWithThumbnailRibbonOverlappingPreview() {
        
        let hasBottomContinueButton = (continueButtonPlacement == .bottom)
        
        // Controls
        //
        let cameraControlsViewBottomPadding = isRedesignedMediaPickerEnabled
            ? Spec.CameraControlsView.newInsets.bottom
            : Spec.CameraControlsView.legacyInsets.bottom
        let cameraControlsViewHeight = isRedesignedMediaPickerEnabled
            ? Spec.CameraControlsView.newHeight
            : Spec.CameraControlsView.legacyHeight
        let cameraControlsViewBottom = hasBottomContinueButton
            ? bottomContinueButton.top - cameraControlsViewBottomPadding
            : bounds.bottom - paparazzoSafeAreaInsets.bottom
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsViewBottom,
            height: cameraControlsViewHeight
        )
        photoControlsView.frame = cameraControlsView.frame
        
        let topInset = isRedesignedMediaPickerEnabled
            ? Spec.ThumbnailRibbonView.newInsets.bottom
            : Spec.ThumbnailRibbonView.legacyInsets.bottom
        let previewTargetBottom = cameraControlsView.top - (hasBottomContinueButton ? 8 : 0) - topInset
        
        // Thumbnail ribbon
        //
        let thumbnailRibbonViewHeight = isRedesignedMediaPickerEnabled
            ? Spec.ThumbnailRibbonView.newHeight
            : Spec.ThumbnailRibbonView.legacyHeight
        thumbnailRibbonView.backgroundColor = theme?.thumbnailsViewBackgroundColor.withAlphaComponent(0.6)
        let contentInsets = isRedesignedMediaPickerEnabled
            ? Spec.ThumbnailRibbonView.newContentInsets
            : Spec.ThumbnailRibbonView.legacyContentInsets
        thumbnailRibbonView.contentInsets = contentInsets
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: previewTargetBottom,
            height: thumbnailRibbonViewHeight
        )
        
        // Camera stream / photo preview area
        //
        let photoPreviewViewBottom = isRedesignedMediaPickerEnabled
            ? thumbnailRibbonView.top - Spec.ThumbnailRibbonView.newInsets.top
            : previewTargetBottom
        photoPreviewView.layout(
            left: bounds.left,
            right: bounds.right,
            top: notchMaskingView.bottom,
            bottom: photoPreviewViewBottom
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
        thumbnailRibbonView.contentInsets = isRedesignedMediaPickerEnabled
            ? Spec.ThumbnailRibbonView.newContentInsets
            : Spec.ThumbnailRibbonView.legacyContentInsets
        let thumbnailRibbonViewTopInset = isRedesignedMediaPickerEnabled
            ? Spec.ThumbnailRibbonView.newInsets.bottom
            : Spec.ThumbnailRibbonView.legacyInsets.bottom
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top - thumbnailRibbonViewTopInset,
            height: thumbnailRibbonHeight
        )
        
        // Camera stream / photo preview area
        //
        let photoPreviewViewBottomInset = isRedesignedMediaPickerEnabled
            ? Spec.ThumbnailRibbonView.newInsets.top
            : Spec.ThumbnailRibbonView.legacyInsets.top
        let photoPreviewViewTopInset = isRedesignedMediaPickerEnabled
            ? Spec.PhotoPreviewView.newInsets.top
            : Spec.PhotoPreviewView.legacyInsets.top
        photoPreviewView.layout(
            left: bounds.left,
            right: bounds.right,
            top: notchMaskingView.bottom + photoPreviewViewTopInset,
            bottom: thumbnailRibbonView.top - photoPreviewViewBottomInset
        )
    }
    
    private func layOutPhotoTitleLabel() {
        photoTitleLabel.sizeToFit()
        photoTitleLabel.centerX = bounds.centerX
        photoTitleLabel.top = max(notchMaskingView.bottom, fakeNavigationBarMinimumYOffset) + fakeNavigationBarContentTopInset + 9
    }
    
    private func layoutBadgeView() {
        imagePerceptionBadgeView.layout(
            left: bounds.left + Spec.PerceptionBadge.insets.left,
            top: paparazzoSafeAreaInsets.top + Spec.PerceptionBadge.insets.top,
            width: imagePerceptionBadgeView.sizeThatFits().width,
            height: imagePerceptionBadgeView.sizeThatFits().height
        )
    }
    
    // MARK: - ThemeConfigurable
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        backgroundColor = theme.mediaPickerBackgroundColor
        notchMaskingView.backgroundColor = theme.mediaPickerBackgroundColor
        photoPreviewView.backgroundColor = theme.photoPreviewBackgroundColor
        photoPreviewView.collectionViewBackgroundColor = theme.photoPreviewCollectionBackgroundColor
        
        photoTitleLabel.font = theme.mediaPickerTitleFont
        photoTitleLabelLightTextColor = theme.mediaPickerTitleLightColor
        photoTitleLabelDarkTextColor = theme.mediaPickerTitleDarkColor
        
        thumbnailRibbonView.isRedesignedMediaPickerEnabled = isRedesignedMediaPickerEnabled
        
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
        
        if isRedesignedMediaPickerEnabled {
            bottomContinueButton.clipsToBounds = true
            bottomContinueButton.layer.cornerRadius = Spec.BottomContinueButton.newCornerRadius
            bottomContinueButton.setBackgroundColor(theme.mediaPickerDoneButtonColor, for: .normal)
            bottomContinueButton.setBackgroundColor(theme.mediaPickerDoneButtonHighlightedColor, for: .highlighted)
            
            bottomContinueButtonContainer.layer.shadowColor = theme.mediaPickerDoneButtonColor.cgColor
            bottomContinueButtonContainer.backgroundColor = theme.mediaPickerBackgroundColor
            
            bottomContinueButtonContainerShapeLayer.fillColor = theme.mediaPickerBackgroundColor.cgColor
            bottomContinueButtonContainerShapeLayer.backgroundColor = theme.mediaPickerBackgroundColor.cgColor
            bottomContinueButtonContainerShapeLayer.shadowColor = theme.mediaPickerDoneButtonColor.cgColor
        } else {
            bottomContinueButton.layer.cornerRadius = Spec.BottomContinueButton.legacyCornerRadius
            bottomContinueButton.setBackgroundColor(theme.cameraBottomContinueButtonBackgroundColor, for: .normal)
            bottomContinueButton.setBackgroundColor(theme.cameraBottomContinueButtonHighlightedBackgroundColor, for: .highlighted)
        }
        
        bottomContinueButton.titleLabel?.font = theme.cameraBottomContinueButtonFont
        bottomContinueButton.setTitleColor(theme.cameraBottomContinueButtonTitleColor, for: .normal)

        closeButton.tintColor = theme.mediaPickerIconColor
        let highlightedImage = closeButton
            .image(for: .normal)?
            .withTintColor(theme.buttonGrayHighlightedColor, renderingMode: .alwaysOriginal)
        closeButton.setImage(highlightedImage, for: .highlighted)
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
    
    var onAutoEnhanceButtonTap: (() -> ())? {
        get { return photoControlsView.onAutoEnhanceButtonTap }
        set { photoControlsView.onAutoEnhanceButtonTap = newValue }
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
        
    func setAutoEnhanceStatus(_ status: MediaPickerAutoEnhanceStatus) {
        switch status {
        case .original:
            photoControlsView.setAutoEnhanceButtonStatus(.original)
        case .enhanced:
            photoControlsView.setAutoEnhanceButtonStatus(.enhanced)
        case .disabled:
            photoControlsView.setAutoEnhanceButtonStatus(.disabled)
        }
    }
    
    func setImagePerceptionBadge(_ viewData: ImagePerceptionBadgeViewData) {
        imagePerceptionBadgeView.setViewData(viewData)
        setNeedsLayout()
        layoutIfNeeded()
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
        bottomContinueButtonContainer.isHidden = !isVisible
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
    
    func updateItem(previousItem: MediaPickerItem, newItem: MediaPickerItem) {
        photoPreviewView.updateItem(previousItem: previousItem, newItem: newItem)
        thumbnailRibbonView.updateItem(previousItem: previousItem, newItem: newItem)
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
    
    func moveItemThumbnail(from sourceIndex: Int, to destinationIndex: Int) {
        thumbnailRibbonView.moveItemThumbnail(from: sourceIndex, to: destinationIndex)
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
    
    func setShowsRemoveButton(_ showsRemoveButton: Bool) {
        if showsRemoveButton {
            photoControlsView.mode.insert(.hasRemoveButton)
        } else {
            photoControlsView.mode.remove(.hasRemoveButton)
        }
    }
    
    func setShowsAutoEnhanceButton(_ showsAutoEnhanceButton: Bool) {
        if showsAutoEnhanceButton {
            photoControlsView.mode.insert(.hasAutoEnhanceButton)
        } else {
            photoControlsView.mode.remove(.hasAutoEnhanceButton)
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
    
    // MARK: - Spec
    
    private enum Spec {
        enum PerceptionBadge {
            static let insets = UIEdgeInsets(top: 56, left: 8, bottom: 0, right: 0)
        }
        
        enum CameraControlsView {
            static let newInsets = UIEdgeInsets(top: 0, left: 0, bottom: 26, right: 0)
            static let legacyInsets = UIEdgeInsets.zero
            
            static let newHeight = 60.0
            static let legacyHeight = 93.0
        }
        
        enum BottomContinueButton {
            static let newHeight = 52.0
            static let legacyHeight = 36.0
            
            static let newInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            static let legacyInsets = UIEdgeInsets(top: 0, left: 16, bottom: 14, right: 16)
            
            static let newCornerRadius = 16.0
            static let legacyCornerRadius = 5.0
        }
        
        enum bottomContinueButtonContainerShapeLayer {
            static let cornerRadius = 24.0
        }
        
        enum ThumbnailRibbonView {
            static let newHeight = 108.0
            static let legacyHeight = 72.0
            
            static let newContentInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            static let legacyContentInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            
            static let newInsets = UIEdgeInsets(top: 6, left: 0, bottom: 16, right: 0)
            static let legacyInsets = UIEdgeInsets.zero
        }
        
        enum PhotoPreviewView {
            static let newInsets = UIEdgeInsets(top: 52, left: 0, bottom: 0, right: 0)
            static let legacyInsets = UIEdgeInsets.zero
        }
    }
}

private extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}
