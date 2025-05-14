import UIKit
import AVFoundation
import MediaPlayer

final class MedicalBookCameraViewController:
    PaparazzoViewController,
    MedicalBookCameraViewInput
{
    // MARK: - Private properties
    private let deviceOrientationService: DeviceOrientationService

    private let medicalBookCameraView = MedicalBookCameraView()
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return medicalBookCameraView.cameraOutputLayer
    }
    
    // MARK: - Init
    init(deviceOrientationService: DeviceOrientationService) {
        self.deviceOrientationService = deviceOrientationService
        super.init()
        transitioningDelegate = PhotoLibraryToCameraTransitioningDelegate.shared
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = medicalBookCameraView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideVolumeView()
        configure()
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        previewLayer?.connection?.videoOrientation = deviceOrientationService.currentOrientation.toAVCaptureVideoOrientation
    }
    
    // MARK: - Configure
    private func configure() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        deviceOrientationService.onOrientationChange = { [weak self] deviceOrientation in
            self?.medicalBookCameraView.rotateButtons(nextTransform: CGAffineTransform(deviceOrientation: deviceOrientation))
        }
    }
    
    private func hideVolumeView() {
        let volView = MPVolumeView(frame: .init(x: 10000, y: 10000, width: 0, height: 0))
        view.addSubview(volView)
    }
    
    // MARK: - MedicalBookCameraViewInput
    
    var onViewWillAppear: ((Bool) -> ())?
    var onViewDidDisappear: ((Bool) -> ())?
    var onViewDidLayoutSubviews: (() -> ())?
    
    var onCloseButtonTap: (() -> ())? {
        get { medicalBookCameraView.onCloseButtonTap }
        set { medicalBookCameraView.onCloseButtonTap = newValue }
    }
    
    var onToggleCameraButtonTap: (() -> ())? {
        get { medicalBookCameraView.onToggleCameraButtonTap }
        set { medicalBookCameraView.onToggleCameraButtonTap = newValue }
    }
    var onFlashToggle: ((Bool) -> ())? {
        get { medicalBookCameraView.onFlashToggle }
        set { medicalBookCameraView.onFlashToggle = newValue }
    }
    
    var onDoneButtonTap: (() -> ())? {
        get { medicalBookCameraView.onDoneButtonTap }
        set { medicalBookCameraView.onDoneButtonTap = newValue }
    }
    
    var onShutterButtonTap: (() -> ())? {
        get { medicalBookCameraView.onShutterButtonTap }
        set { medicalBookCameraView.onShutterButtonTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { medicalBookCameraView.onLastPhotoThumbnailTap }
        set { medicalBookCameraView.onLastPhotoThumbnailTap = newValue }
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { medicalBookCameraView.onAccessDeniedButtonTap }
        set { medicalBookCameraView.onAccessDeniedButtonTap = newValue }
    }
    
    func setFlashButtonVisible(_ flag: Bool) {
        medicalBookCameraView.setFlashButtonVisible(flag)
    }
    
    func setFlashButtonOn(_ flag: Bool) {
        medicalBookCameraView.setFlashButtonOn(flag)
    }
    
    func animateShot() {
        medicalBookCameraView.animateShot()
    }
    
    func setShutterButtonEnabled(_ flag: Bool, _ animated: Bool) {
        medicalBookCameraView.setShutterButtonEnabled(flag, animated: animated)
    }
    
    func setHintText(_ text: String) {
        medicalBookCameraView.setHintText(text)
    }
    
    func setDoneButtonTitle(_ text: String) {
        medicalBookCameraView.setDoneButtonTitle(text)
    }
    
    func setDoneButtonVisible(_ flag: Bool) {
        medicalBookCameraView.setDoneButtonVisible(flag)
    }
    
    func setSelectedData(_ viewData: SelectedPhotosViewData?, animated: Bool) {
        medicalBookCameraView.setSelectedData(viewData, animated: animated)
    }
    
    func setSelectedDataEnabled(_ flag: Bool) {
        medicalBookCameraView.setSelectedDataEnabled(flag)
    }
    
    func setAccessDeniedViewVisible(_ flag: Bool) {
        medicalBookCameraView.setAccessDeniedViewVisible(flag)
    }
    
    func setAccessDeniedTitle(_ title: String) {
        medicalBookCameraView.setAccessDeniedTitle(title)
    }
    
    func setAccessDeniedMessage(_ message: String) {
        medicalBookCameraView.setAccessDeniedMessage(message)
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        medicalBookCameraView.setAccessDeniedButtonTitle(title)
    }
    
    // MARK: - CameraV3ViewController
    func setTheme(_ theme: MedicalBookCameraUITheme) {
        medicalBookCameraView.setTheme(theme)
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        medicalBookCameraView.setPreviewLayer(previewLayer)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
