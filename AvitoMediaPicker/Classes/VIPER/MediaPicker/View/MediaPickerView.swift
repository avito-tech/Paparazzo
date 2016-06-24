import UIKit
import AvitoDesignKit
import AVFoundation

final class MediaPickerView: UIView, MediaRibbonLayoutDelegate {
    
    // MARK: - Subviews
    
    private var cameraView: UIView?
    private let photoView = PhotoPreviewView()
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    private let photoLibraryPeepholeView = UIImageView()
    private let closeButton = UIButton()
    private let continueButton = UIButton()
    private let flashView = UIView()
    
    private let mediaRibbonLayout = MediaRibbonLayout()
    private let mediaRibbonView: UICollectionView
    
    private var closeAndContinueButtonsSwapped = false
    
    // MARK: - Constants
    
    private let cameraAspectRatio = CGFloat(4) / CGFloat(3)
    
    private let controlsCompactHeight = CGFloat(54) // (iPhone 4 height) - (iPhone 4 width) * 4/3 (photo aspect ratio) = 53,333...
    private let controlsExtendedHeight = CGFloat(83)
    
    private let mediaRibbonMinHeight = CGFloat(72)
    private let mediaRibbonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let mediaRibbonInteritemSpacing = CGFloat(7)
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // MARK: - Helpers
    
    private let mediaRibbonDataSource = MediaRibbonDataSource()
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        mediaRibbonLayout.scrollDirection = .Horizontal
        mediaRibbonLayout.sectionInset = mediaRibbonInsets
        mediaRibbonLayout.minimumLineSpacing = mediaRibbonInteritemSpacing
        
        mediaRibbonView = UICollectionView(frame: .zero, collectionViewLayout: mediaRibbonLayout)
        mediaRibbonView.backgroundColor = .whiteColor()
        mediaRibbonView.showsHorizontalScrollIndicator = false
        mediaRibbonView.showsVerticalScrollIndicator = false
        
        super.init(frame: .zero)
        
        backgroundColor = .whiteColor()
        
        photoView.contentMode = .ScaleAspectFill
        photoView.clipsToBounds = true
        
        flashView.backgroundColor = .whiteColor()
        flashView.alpha = 0
        
        mediaRibbonDataSource.setUpInCollectionView(mediaRibbonView)
        
        mediaRibbonView.dataSource = mediaRibbonDataSource
        mediaRibbonView.delegate = self
        
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
        
        addSubview(flashView)
        addSubview(photoView)
        addSubview(mediaRibbonView)
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
        
        photoView.frame = cameraFrame
        cameraView?.frame = cameraFrame
        
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: controlsHeight
        )
        
        photoControlsView.frame = cameraControlsView.frame

        let photoRibbonHeight = max(mediaRibbonMinHeight, cameraControlsView.top - photoView.bottom)

        mediaRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: photoRibbonHeight
        )

        let mediaRibbonAlpha: CGFloat = (cameraControlsView.top < cameraFrame.bottom) ? 0.6 : 1
        mediaRibbonView.backgroundColor = mediaRibbonView.backgroundColor?.colorWithAlphaComponent(mediaRibbonAlpha)
        
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
    
    var onCameraVisibilityChange: ((isCameraVisible: Bool) -> ())?
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
            photoView.hidden = true
            photoView.image = nil
            
            cameraControlsView.hidden = false
            photoControlsView.hidden = true
            
            mediaRibbonView.selectItemAtIndexPath(
                mediaRibbonDataSource.indexPathForCameraCell(),
                animated: false,
                scrollPosition: .None
            )
            
            setCameraVisible(true)
        
        case .PhotoPreview(let photo):
            
            photoView.setImage(photo.image, deferredPlaceholder: true) { [weak self] in
                self?.photoView.hidden = false
                self?.setCameraVisible(false)
            }
            
            cameraControlsView.hidden = true
            photoControlsView.hidden = false
        }
    }
    
    func setCameraButtonVisible(visible: Bool) {
        mediaRibbonDataSource.cameraCellVisible = visible
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
        mediaRibbonDataSource.addItems(items)
    }

    func removeItem(item: MediaPickerItem) {
        mediaRibbonDataSource.removeItem(item)
    }
    
    func selectItem(item: MediaPickerItem) {
        if let indexPath = mediaRibbonDataSource.indexPathForItem(item) {
            mediaRibbonView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
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
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
        
        closeAndContinueButtonsSwapped = (orientation == .LandscapeLeft)
        
        closeButton.transform = transform
        continueButton.transform = transform
        
        photoView.setImageTranform(transform)
        
        cameraControlsView.setControlsTransform(transform)
        photoControlsView.setControlsTransform(transform)
        
        mediaRibbonLayout.itemsTransform = transform
        mediaRibbonLayout.invalidateLayout()
        
        mediaRibbonDataSource.cameraIconTransform = transform
    }
    
    func setCameraView(view: UIView) {
        cameraView?.removeFromSuperview()
        cameraView = view
        insertSubview(view, atIndex: 0)
    }
    
    func setCaptureSession(session: AVCaptureSession) {
        mediaRibbonDataSource.captureSession = session
    }
    
    func setContinueButtonTitle(title: String) {
        continueButton.setTitle(title, forState: .Normal)
        continueButton.size = CGSizeMake(continueButton.sizeThatFits().width, continueButtonHeight)
    }
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {

        cameraControlsView.setTheme(theme)
        photoControlsView.setTheme(theme)
        mediaRibbonDataSource.setTheme(theme)

        continueButton.setTitleColor(theme.cameraContinueButtonTitleColor, forState: .Normal)
        continueButton.titleLabel?.font = theme.cameraContinueButtonTitleFont

        closeButton.setImage(theme.closeCameraIcon, forState: .Normal)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch mediaRibbonDataSource[indexPath] {
        case .Photo(let photo):
            onItemSelect?(photo)
        case .Camera:
            onReturnToCameraTap?()
        }
    }
    
    // MARK: - MediaRibbonLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = mediaRibbonView.height - mediaRibbonInsets.top - mediaRibbonInsets.bottom
        return CGSize(width: height, height: height)
    }
    
    func shouldApplyTransformToItemAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if case .Photo(_) = mediaRibbonDataSource[indexPath] {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Private
    
    private func setCameraVisible(visible: Bool) {
        cameraView?.hidden = !visible
        onCameraVisibilityChange?(isCameraVisible: visible)
    }
    
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