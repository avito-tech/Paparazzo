import UIKit
import AVFoundation
import AvitoDesignKit

final class MediaPickerViewController: UIViewController, MediaPickerViewInput {
    
    private let mediaPickerView = MediaPickerView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = mediaPickerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        onViewDidLoad?()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onPreviewSizeDetermined?(previewSize: mediaPickerView.previewSize)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - MediaPickerViewInput
    
    var onShutterButtonTap: (() -> ())? {
        get { return mediaPickerView.onShutterButtonTap }
        set { mediaPickerView.onShutterButtonTap = newValue }
    }

    var onPhotoLibraryButtonTap: (() -> ())? {
        get { return mediaPickerView.onPhotoLibraryButtonTap }
        set { mediaPickerView.onPhotoLibraryButtonTap = newValue }
    }

    var onFlashToggle: (Bool -> ())? {
        get { return mediaPickerView.onFlashToggle }
        set { mediaPickerView.onFlashToggle = newValue }
    }
    
    var onItemSelect: (MediaPickerItem -> ())? {
        get { return mediaPickerView.onItemSelect }
        set { mediaPickerView.onItemSelect = newValue }
    }
    
    var onRemoveButtonTap: (() -> ())? {
        get { return mediaPickerView.onRemoveButtonTap }
        set { mediaPickerView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return mediaPickerView.onCropButtonTap }
        set { mediaPickerView.onCropButtonTap = newValue }
    }
    
    var onCameraThumbnailTap: (() -> ())? {
        get { return mediaPickerView.onCameraThumbnailTap }
        set { mediaPickerView.onCameraThumbnailTap = newValue }
    }
    
    var onSwipeToItem: (MediaPickerItem -> ())? {
        get { return mediaPickerView.onSwipeToItem }
        set { mediaPickerView.onSwipeToItem = newValue }
    }
    
    var onSwipeToCamera: (() -> ())? {
        get { return mediaPickerView.onSwipeToCamera }
        set { mediaPickerView.onSwipeToCamera = newValue }
    }
    
    var onSwipeToCameraProgressChange: (CGFloat -> ())? {
        get { return mediaPickerView.onSwipeToCameraProgressChange }
        set { mediaPickerView.onSwipeToCameraProgressChange = newValue }
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return mediaPickerView.onAccessDeniedButtonTap }
        set { mediaPickerView.onAccessDeniedButtonTap = newValue }
    }
    
    var onViewDidLoad: (() -> ())?
    var onPreviewSizeDetermined: ((previewSize: CGSize) -> ())?
    
    func setMode(mode: MediaPickerViewMode) {
        // Этот метод может быть вызван до того, как вьюшка обретет frame, что критично для корректной работы
        // ее метода setMode. dispatch_async спасает ситуацию.
        dispatch_async(dispatch_get_main_queue()) {
            self.mediaPickerView.setMode(mode)
        }
    }
    
    func setCameraOutputParameters(parameters: CameraOutputParameters) {
        mediaPickerView.setCameraOutputParameters(parameters)
    }
    
    func setCameraOutputOrientation(orientation: ExifOrientation) {
        mediaPickerView.setCameraOutputOrientation(orientation)
    }
    
    func setPhotoTitle(title: String) {
        mediaPickerView.setPhotoTitle(title)
    }
    
    func setPhotoTitleStyle(style: MediaPickerTitleStyle) {
        mediaPickerView.setPhotoTitleStyle(style)
    }
    
    func setPhotoTitleAlpha(alpha: CGFloat) {
        mediaPickerView.setPhotoTitleAlpha(alpha)
    }
    
    func setContinueButtonTitle(title: String) {
        mediaPickerView.setContinueButtonTitle(title)
    }
    
    func setContinueButtonEnabled(enabled: Bool) {
        mediaPickerView.setContinueButtonEnabled(enabled)
    }
    
    func adjustForDeviceOrientation(orientation: DeviceOrientation) {
        UIView.animateWithDuration(0.25) {
            self.mediaPickerView.adjustForDeviceOrientation(orientation)
        }
    }
    
    func setLatestLibraryPhoto(image: ImageSource?) {
        mediaPickerView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(visible: Bool) {
        mediaPickerView.setFlashButtonVisible(visible)
    }
    
    func setFlashButtonOn(isOn: Bool) {
        mediaPickerView.setFlashButtonOn(isOn)
    }
    
    func animateFlash() {
        mediaPickerView.animateFlash()
    }
    
    var onCloseButtonTap: (() -> ())? {
        get { return mediaPickerView.onCloseButtonTap }
        set { mediaPickerView.onCloseButtonTap = newValue }
    }
    
    var onContinueButtonTap: (() -> ())? {
        get { return mediaPickerView.onContinueButtonTap }
        set { mediaPickerView.onContinueButtonTap = newValue }
    }
    
    var onCameraToggleButtonTap: (() -> ())? {
        get { return mediaPickerView.onCameraToggleButtonTap }
        set { mediaPickerView.onCameraToggleButtonTap = newValue }
    }
    
    func setCameraToggleButtonVisible(visible: Bool) {
        mediaPickerView.setCameraToggleButtonVisible(visible)
    }
    
    func setAccessDeniedViewVisible(visible: Bool) {
        mediaPickerView.setAccessDeniedViewVisible(visible)
    }
    
    func setAccessDeniedTitle(title: String) {
        mediaPickerView.setAccessDeniedTitle(title)
    }
    
    func setAccessDeniedMessage(message: String) {
        mediaPickerView.setAccessDeniedMessage(message)
    }
    
    func setAccessDeniedButtonTitle(title: String) {
        mediaPickerView.setAccessDeniedButtonTitle(title)
    }

    func addItems(items: [MediaPickerItem], animated: Bool) {
        mediaPickerView.addItems(items, animated: animated)
    }
    
    func updateItem(item: MediaPickerItem) {
        mediaPickerView.updateItem(item)
    }
    
    func removeItem(item: MediaPickerItem) {
        mediaPickerView.removeItem(item)
    }
    
    func selectItem(item: MediaPickerItem) {
        mediaPickerView.selectItem(item)
        onItemSelect?(item)
    }
    
    func scrollToItemThumbnail(item: MediaPickerItem, animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.mediaPickerView.scrollToItemThumbnail(item, animated: animated)
        }
    }
    
    func selectCamera() {
        mediaPickerView.selectCamera()
        onCameraThumbnailTap?()
    }
    
    func scrollToCameraThumbnail(animated animated: Bool) {
        mediaPickerView.scrollToCameraThumbnail(animated: animated)
    }
    
    func setCameraControlsEnabled(enabled: Bool) {
        mediaPickerView.setCameraControlsEnabled(enabled)
    }
    
    func setCameraButtonVisible(visible: Bool) {
        mediaPickerView.setCameraButtonVisible(visible)
    }
    
    func setShutterButtonEnabled(enabled: Bool) {
        mediaPickerView.setShutterButtonEnabled(enabled)
    }
    
    // MARK: - MediaPickerViewController
    
    func setCameraView(view: UIView) {
        mediaPickerView.setCameraView(view)
    }
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {
        mediaPickerView.setTheme(theme)
    }
    
    func setShowsCropButton(showsCropButton: Bool) {
        mediaPickerView.setShowsCropButton(showsCropButton)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}
