import UIKit
import AVFoundation

final class CameraViewController: BaseViewControllerSwift, CameraViewInput {
    
    private var cameraView = CameraView()
    
    override func loadView() {
        view = cameraView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        onCameraVisibilityChange?(isCameraVisible: true)
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
        get { return cameraView.onShutterButtonTap }
        set { cameraView.onShutterButtonTap = newValue }
    }

    var onPhotoLibraryButtonTap: (() -> ())? {
        get { return cameraView.onPhotoLibraryButtonTap }
        set { cameraView.onPhotoLibraryButtonTap = newValue }
    }

    var onFlashToggle: (Bool -> ())? {
        get { return cameraView.onFlashToggle }
        set { cameraView.onFlashToggle = newValue }
    }
    
    var onCameraVisibilityChange: ((isCameraVisible: Bool) -> ())? {
        get { return cameraView.onCameraVisibilityChange }
        set { cameraView.onCameraVisibilityChange = newValue }
    }
    
    var onPhotoSelect: (PhotoPickerItem -> ())? {
        get { return cameraView.onPhotoSelect }
        set { cameraView.onPhotoSelect = newValue }
    }
    
    var onRemoveButtonTap: (() -> ())? {
        get { return cameraView.onRemoveButtonTap }
        set { cameraView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return cameraView.onCropButtonTap }
        set { cameraView.onCropButtonTap = newValue }
    }
    
    var onReturnToCameraTap: (() -> ())? {
        get { return cameraView.onReturnToCameraTap }
        set { cameraView.onReturnToCameraTap = newValue }
    }
    
    func setMode(mode: CameraViewMode) {
        cameraView.setMode(mode)
    }
    
    func adjustForDeviceOrientation(orientation: DeviceOrientation) {
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
        
        UIView.animateWithDuration(0.25) {
            self.cameraView.setControlsTransform(transform)
        }
    }
    
    func setCaptureSession(session: AVCaptureSession) {
        cameraView.setCaptureSession(session)
    }
    
    func setLatestLibraryPhoto(image: LazyImage?) {
        cameraView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(visible: Bool) {
        cameraView.setFlashButtonVisible(visible)
    }
    
    func animateFlash() {
        cameraView.animateFlash()
    }

    func addPhotoRibbonItem(photo: PhotoPickerItem) {
        cameraView.addPhoto(photo)
    }
    
    func removeSelectionInPhotoRibbon() {
        cameraView.removeSelectionInPhotoRibbon()
    }
    
    func startSpinnerForNewPhoto() {
        cameraView.startSpinnerForNewPhoto()
    }
    
    func stopSpinnerForNewPhoto() {
        cameraView.stopSpinnerForNewPhoto()
    }
}
