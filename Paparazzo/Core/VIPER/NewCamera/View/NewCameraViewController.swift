import AVFoundation
import ImageSource // TODO: delete
import UIKit

final class NewCameraViewController:
    PaparazzoViewController,
    NewCameraViewInput
{
    // MARK: - Private properties
    private let cameraView = NewCameraView()
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return cameraView.cameraOutputLayer
    }
    
    // MARK: - Init
    override init() {
        super.init()
        transitioningDelegate = PhotoLibraryToCameraTransitioningDelegate.shared
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Orientation
    override public var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return super.preferredInterfaceOrientationForPresentation
        } else {
            return .portrait
        }
    }
    
    // MARK: - Lifecycle
    override var prefersStatusBarHidden: Bool {
        return !UIDevice.current.hasTopSafeAreaInset
    }
    
    override func loadView() {
        view = cameraView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onViewWillAppear?(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDidDisappear?(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        onViewDidLayoutSubviews?()
    }
    
    // MARK: - NewCameraViewInput
    var onViewWillAppear: ((_ animated: Bool) -> ())?
    var onViewDidDisappear: ((_ animated: Bool) -> ())?
    var onViewDidLayoutSubviews: (() -> ())?
    
    var onCloseButtonTap: (() -> ())? {
        get { return cameraView.onCloseButtonTap }
        set { cameraView.onCloseButtonTap = newValue }
    }
    
    var onDoneButtonTap: (() -> ())? {
        get { return cameraView.onDoneButtonTap }
        set { cameraView.onDoneButtonTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { return cameraView.onLastPhotoThumbnailTap }
        set { cameraView.onLastPhotoThumbnailTap = newValue }
    }
    
    var onToggleCameraButtonTap: (() -> ())? {
        get { return cameraView.onToggleCameraButtonTap }
        set { cameraView.onToggleCameraButtonTap = newValue }
    }
    
    var onFlashToggle: ((Bool) -> ())? {
        get { return cameraView.onFlashToggle }
        set { cameraView.onFlashToggle = newValue }
    }
    
    var onCaptureButtonTap: (() -> ())? {
        get { return cameraView.onCaptureButtonTap }
        set { cameraView.onCaptureButtonTap = newValue }
    }
    
    func setFlashButtonVisible(_ isVisible: Bool) {
        cameraView.setFlashButtonVisible(isVisible)
    }
    
    func setFlashButtonOn(_ isOn: Bool) {
        cameraView.setFlashButtonOn(isOn)
    }
    
    func setCaptureButtonState(_ state: CaptureButtonState) {
        cameraView.setCaptureButtonState(state)
    }
    
    func setLatestPhotoLibraryItemImage(_ imageSource: ImageSource?) {
        cameraView.setLatestPhotoLibraryItemImage(imageSource)
    }
    
    func setSelectedPhotosBarState(_ state: SelectedPhotosBarState, completion: @escaping () -> ()) {
        cameraView.setSelectedPhotosBarState(state, completion: completion)
    }
    
    func setHintText(_ hintText: String) {
        cameraView.setHintText(hintText)
    }
    
    func setDoneButtonTitle(_ title: String) {
        cameraView.setDoneButtonTitle(title)
    }
    
    func setPlaceholderText(_ text: String) {
        cameraView.setPlaceholderText(text)
    }
    
    func animateFlash() {
        cameraView.animateFlash()
    }
    
    func animateCapturedPhoto(
        _ image: ImageSource,
        completion: @escaping (_ finalizeAnimation: @escaping () -> ()) -> ())
    {
        cameraView.animateCapturedPhoto(image, completion: completion)
    }
    
    // MARK: - NewCameraViewController
    func setTheme(_ theme: NewCameraUITheme) {
        cameraView.setTheme(theme)
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        cameraView.setPreviewLayer(previewLayer)
    }
    
    func previewFrame(forBounds bounds: CGRect) -> CGRect {
        return cameraView.previewFrame(forBounds: bounds)
    }
}
