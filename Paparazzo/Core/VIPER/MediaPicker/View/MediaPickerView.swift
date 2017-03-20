import ImageSource
import UIKit

final class MediaPickerView: UIView {
    
    // MARK: - Subviews
    
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    
    private let photoLibraryPeepholeView = UIImageView()
    private let closeButton = UIButton()
    private let continueButton = UIButton()
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
    private let controlsExtendedHeight = CGFloat(80)
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // MARK: - Helpers
    
    private var mode = MediaPickerViewMode.camera
    private var deviceOrientation = DeviceOrientation.portrait
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        thumbnailRibbonView = ThumbnailsView()
        photoPreviewView = PhotoPreviewView()
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        flashView.backgroundColor = .white
        flashView.alpha = 0
        
        setupButtons()
        
        photoTitleLabel.textColor = .white
        photoTitleLabel.layer.shadowOffset = .zero
        photoTitleLabel.layer.shadowOpacity = 0.5
        photoTitleLabel.layer.shadowRadius = 2
        photoTitleLabel.layer.masksToBounds = false
        photoTitleLabel.alpha = 0
        
        photoLibraryPeepholeView.contentMode = .scaleAspectFill
        
        thumbnailRibbonView.onPhotoItemSelect = { [weak self] mediaPickerItem in
            self?.onItemSelect?(mediaPickerItem)
        }
        
        thumbnailRibbonView.onCameraItemSelect = { [weak self] in
            self?.onCameraThumbnailTap?()
        }
        
        thumbnailRibbonView.onItemMove = { [weak self] (sourceIndex, destinationIndex) in
            self?.onItemMove?(sourceIndex, destinationIndex)
        }
        
        addSubview(photoPreviewView)
        addSubview(flashView)
        addSubview(thumbnailRibbonView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(closeButton)
        addSubview(photoTitleLabel)
        addSubview(continueButton)
        
        setMode(.camera)
    }
    
    private func setupButtons() {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cameraFrame = CGRect(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: bounds.size.width * cameraAspectRatio
        )
        
        let freeSpaceUnderCamera = bounds.bottom - cameraFrame.bottom
        let canFitExtendedControls = (freeSpaceUnderCamera >= controlsExtendedHeight)
        let controlsHeight = canFitExtendedControls ? controlsExtendedHeight : controlsCompactHeight
        
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
    
    func setCameraControlsEnabled(_ enabled: Bool) {
        cameraControlsView.setCameraControlsEnabled(enabled)
    }
    
    func setCameraButtonVisible(_ visible: Bool) {
        photoPreviewView.setCameraVisible(visible)
        thumbnailRibbonView.setCameraItemVisible(visible)
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
        layoutPhotoTitleLabel()
    }
    
    func setPhotoTitleStyle(_ style: MediaPickerTitleStyle) {
        switch style {
        case .dark:
            photoTitleLabel.textColor = .black
            photoTitleLabel.layer.shadowOpacity = 0
        case .light:
            photoTitleLabel.textColor = .white
            photoTitleLabel.layer.shadowOpacity = 0.5
        }
    }
    
    func setPhotoTitleAlpha(_ alpha: CGFloat) {
        photoTitleLabel.alpha = alpha
    }
    
    func setContinueButtonTitle(_ title: String) {
        continueButton.setTitle(title, for: .normal)
        continueButton.size = CGSize(width: continueButton.sizeThatFits().width, height: continueButtonHeight)
    }
    
    func setContinueButtonEnabled(_ enabled: Bool) {
        continueButton.isEnabled = enabled
    }
    
    func setTheme(_ theme: MediaPickerRootModuleUITheme) {

        cameraControlsView.setTheme(theme)
        photoControlsView.setTheme(theme)
        thumbnailRibbonView.setTheme(theme)

        continueButton.setTitleColor(theme.cameraContinueButtonTitleColor, for: .normal)
        continueButton.titleLabel?.font = theme.cameraContinueButtonTitleFont

        closeButton.setImage(theme.closeCameraIcon, for: .normal)
        
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
    
    func setShowsCropButton(_ showsCropButton: Bool) {
        photoControlsView.setShowsCropButton(showsCropButton)
    }
    
    func reloadCamera() {
        photoPreviewView.reloadCamera()
        thumbnailRibbonView.reloadCamera()
    }
    
    // MARK: - Private
    
    private func layoutCloseAndContinueButtons() {
        
        let leftButton = closeAndContinueButtonsSwapped ? continueButton : closeButton
        let rightButton = closeAndContinueButtonsSwapped ? closeButton : continueButton
        
        leftButton.frame = CGRect(
            x: 8,
            y: 8,
            width: leftButton.width,
            height: leftButton.height
        )
        
        rightButton.frame = CGRect(
            x: bounds.right - 8 - rightButton.width,
            y: 8,
            width: rightButton.width,
            height: rightButton.height
        )
    }
    
    private func layoutPhotoTitleLabel() {
        photoTitleLabel.sizeToFit()
        photoTitleLabel.centerX = bounds.centerX
        photoTitleLabel.centerY = closeButton.centerY
    }
    
    @objc private func onCloseButtonTap(_: UIButton) {
        onCloseButtonTap?()
    }
    
    @objc private func onContinueButtonTap(_: UIButton) {
        onContinueButtonTap?()
    }
}
