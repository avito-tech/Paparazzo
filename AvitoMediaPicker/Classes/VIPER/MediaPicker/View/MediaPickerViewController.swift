import UIKit

final class MediaPickerViewController: UIViewController, MediaPickerViewInput {
    
    private let mediaPickerView = MediaPickerView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = mediaPickerView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        onCameraVisibilityChange?(isCameraVisible: true)    // TODO: if viewMode == .Camera
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        onCameraVisibilityChange?(isCameraVisible: false)
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
    
    var onCameraVisibilityChange: ((isCameraVisible: Bool) -> ())? {
        get { return mediaPickerView.onCameraVisibilityChange }
        set { mediaPickerView.onCameraVisibilityChange = newValue }
    }
    
    var onPhotoSelect: (MediaPickerItem -> ())? {
        get { return mediaPickerView.onPhotoSelect }
        set { mediaPickerView.onPhotoSelect = newValue }
    }
    
    var onRemoveButtonTap: (() -> ())? {
        get { return mediaPickerView.onRemoveButtonTap }
        set { mediaPickerView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return mediaPickerView.onCropButtonTap }
        set { mediaPickerView.onCropButtonTap = newValue }
    }
    
    var onReturnToCameraTap: (() -> ())? {
        get { return mediaPickerView.onReturnToCameraTap }
        set { mediaPickerView.onReturnToCameraTap = newValue }
    }
    
    func setMode(mode: MediaPickerViewMode) {
        mediaPickerView.setMode(mode)
    }
    
    func adjustForDeviceOrientation(orientation: DeviceOrientation) {
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
        
        UIView.animateWithDuration(0.25) {
            self.mediaPickerView.setControlsTransform(transform)
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

    func addPhotoRibbonItem(photo: MediaPickerItem) {
        mediaPickerView.addPhoto(photo)
    }
    
    func removeSelectionInPhotoRibbon() {
        mediaPickerView.removeSelectionInPhotoRibbon()
    }
    
    func startSpinnerForNewPhoto() {
        mediaPickerView.startSpinnerForNewPhoto()
    }
    
    func stopSpinnerForNewPhoto() {
        mediaPickerView.stopSpinnerForNewPhoto()
    }
    
    // MARK: - MediaPickerViewController
    
    func setCameraView(view: UIView) {
        mediaPickerView.setCameraView(view)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}
