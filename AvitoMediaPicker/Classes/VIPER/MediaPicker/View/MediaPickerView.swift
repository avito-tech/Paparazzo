import UIKit
import AvitoDesignKit
import AVFoundation

final class MediaPickerView: UIView {
    
    // MARK: - Subviews
    
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    private let dataSources: [MediaRibbonDataSource]
    
    private let photoLibraryPeepholeView = UIImageView()
    private let closeButton = UIButton()
    private let continueButton = UIButton()
    private let flashView = UIView()
    
    private let thumbnailRibbonView: ThumbnailRibbonView
    private let photoPreviewView: PhotoPreviewView
    
    private var closeAndContinueButtonsSwapped = false
    
    // MARK: - Constants
    
    private let cameraAspectRatio = CGFloat(4) / CGFloat(3)
    
    private let controlsCompactHeight = CGFloat(54) // (iPhone 4 height) - (iPhone 4 width) * 4/3 (photo aspect ratio) = 53,333...
    private let controlsExtendedHeight = CGFloat(83)
    
    private let mediaRibbonMinHeight = CGFloat(72)
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // MARK: - Helpers
    
    private var mode = MediaPickerViewMode.Camera
    private var deviceOrientation = DeviceOrientation.Portrait
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        thumbnailRibbonView = ThumbnailRibbonView()
        photoPreviewView = PhotoPreviewView()
        
        dataSources = [thumbnailRibbonView.dataSource, photoPreviewView.dataSource]
        
        super.init(frame: .zero)
        
        backgroundColor = .whiteColor()
        
        flashView.backgroundColor = .whiteColor()
        flashView.alpha = 0
        
        closeButton.backgroundColor = .whiteColor()
        closeButton.layer.cornerRadius = closeButtonSize.height / 2
        closeButton.size = closeButtonSize
        closeButton.addTarget(
            self,
            action: #selector(MediaPickerView.onCloseButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        continueButton.backgroundColor = .whiteColor()
        continueButton.layer.cornerRadius = continueButtonHeight / 2
        continueButton.contentEdgeInsets = continueButtonContentInsets
        continueButton.addTarget(
            self,
            action: #selector(MediaPickerView.onContinueButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        photoLibraryPeepholeView.contentMode = .ScaleAspectFill
        
        thumbnailRibbonView.onPhotoItemSelect = { [weak self] mediaPickerItem in
            self?.onItemSelect?(mediaPickerItem)
        }
        
        thumbnailRibbonView.onCameraItemSelect = { [weak self] in
            self?.onReturnToCameraTap?()
        }
        
        addSubview(photoPreviewView)
        addSubview(flashView)
        addSubview(thumbnailRibbonView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(closeButton)
        addSubview(continueButton)
        
        setMode(.Camera)
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

        let photoRibbonHeight = max(mediaRibbonMinHeight, cameraControlsView.top - photoPreviewView.bottom)

        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: photoRibbonHeight
        )

        let mediaRibbonAlpha: CGFloat = (cameraControlsView.top < cameraFrame.bottom) ? 0.6 : 1
        thumbnailRibbonView.backgroundColor = thumbnailRibbonView.backgroundColor?.colorWithAlphaComponent(mediaRibbonAlpha)
        
        layoutCloseAndContinueButtons()

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
    
    var onFlashToggle: (Bool -> ())? {
        get { return cameraControlsView.onFlashToggle }
        set { cameraControlsView.onFlashToggle = newValue }
    }
    
    var onItemSelect: (MediaPickerItem -> ())?
    
    var onRemoveButtonTap: (() -> ())? {
        get { return photoControlsView.onRemoveButtonTap }
        set { photoControlsView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return photoControlsView.onCropButtonTap }
        set { photoControlsView.onCropButtonTap = newValue }
    }
    
    var onReturnToCameraTap: (() -> ())? {
        get { return photoControlsView.onCameraButtonTap }
        set { photoControlsView.onCameraButtonTap = newValue }
    }
    
    func setMode(mode: MediaPickerViewMode) {
        
        switch mode {
        
        case .Camera:
            cameraControlsView.hidden = false
            photoControlsView.hidden = true
            
            thumbnailRibbonView.selectCameraItem()
            photoPreviewView.scrollToCamera()
        
        case .PhotoPreview(let photo):
            
            photoPreviewView.scrollToMediaItem(photo)
            // TODO: перенести всю логику
//            photoView.setImage(photo.image, deferredPlaceholder: true) { [weak self] in
//                self?.photoView.hidden = false
//                self?.setCameraVisible(false)
//            }
            
            cameraControlsView.hidden = true
            photoControlsView.hidden = false
        }
        
        self.mode = mode
        
        adjustForDeviceOrientation(deviceOrientation)
    }
    
    func setCameraButtonVisible(visible: Bool) {
        dataSources.forEach { $0.cameraCellVisible = visible }
    }
    
    func setLatestPhotoLibraryItemImage(image: ImageSource?) {
        cameraControlsView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(visible: Bool) {
        cameraControlsView.setFlashButtonVisible(visible)
    }
    
    func setFlashButtonOn(isOn: Bool) {
        cameraControlsView.setFlashButtonOn(isOn)
    }
    
    func animateFlash() {
        
        self.flashView.alpha = 1
        
        UIView.animateWithDuration(
            0.3,
            delay: 0,
            options: [.CurveEaseOut],
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
    
    func setCameraToggleButtonVisible(visible: Bool) {
        cameraControlsView.setCameraToggleButtonVisible(visible)
    }
    
    func setShutterButtonEnabled(enabled: Bool) {
        cameraControlsView.setShutterButtonEnabled(enabled)
    }
    
    func addItems(items: [MediaPickerItem]) {
        dataSources.forEach { $0.addItems(items) }
    }

    func removeItem(item: MediaPickerItem) {
        dataSources.forEach { $0.removeItem(item) }
    }
    
    func selectItem(item: MediaPickerItem) {
        thumbnailRibbonView.selectMediaItem(item)
    }
    
    func startSpinnerForNewPhoto() {
        debugPrint("startSpinnerForNewPhoto")
        // TODO
    }
    
    func stopSpinnerForNewPhoto() {
        debugPrint("stopSpinnerForNewPhoto")
        // TODO
    }
    
    func adjustForDeviceOrientation(orientation: DeviceOrientation) {
        
        deviceOrientation = orientation
        
        var orientation = orientation
        if case .PhotoPreview(_) = mode {
            orientation = .Portrait
        }
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
        
        closeAndContinueButtonsSwapped = (orientation == .LandscapeLeft)
        
        closeButton.transform = transform
        continueButton.transform = transform
        
        cameraControlsView.setControlsTransform(transform)
        photoControlsView.setControlsTransform(transform)
        thumbnailRibbonView.setControlsTransform(transform)
    }
    
    func setCameraView(view: UIView) {
        photoPreviewView.setCameraView(view)
    }
    
    func setCaptureSession(session: AVCaptureSession) {
        thumbnailRibbonView.captureSession = session
    }
    
    func setContinueButtonTitle(title: String) {
        continueButton.setTitle(title, forState: .Normal)
        continueButton.size = CGSizeMake(continueButton.sizeThatFits().width, continueButtonHeight)
    }
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {

        cameraControlsView.setTheme(theme)
        photoControlsView.setTheme(theme)
        thumbnailRibbonView.setTheme(theme)

        continueButton.setTitleColor(theme.cameraContinueButtonTitleColor, forState: .Normal)
        continueButton.titleLabel?.font = theme.cameraContinueButtonTitleFont

        closeButton.setImage(theme.closeCameraIcon, forState: .Normal)
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
    
    @objc private func onCloseButtonTap(sender: UIButton) {
        onCloseButtonTap?()
    }
    
    @objc private func onContinueButtonTap(sender: UIButton) {
        onContinueButtonTap?()
    }
}