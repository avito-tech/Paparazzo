import UIKit
import AVFoundation
import MediaPlayer

final class CameraV3ViewController:
    PaparazzoViewController,
    CameraV3ViewInput
{
    // MARK: - Private properties
    private let deviceOrientationService: DeviceOrientationService
    
    private let cameraView = CameraV3View()
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return cameraView.cameraOutputLayer
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
        view = cameraView
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
            self?.cameraView.rotateButtons(nextTransform: CGAffineTransform(deviceOrientation: deviceOrientation))
        }
    }
    
    private func hideVolumeView() {
        let volView = MPVolumeView(frame: .init(x: 10000, y: 10000, width: 0, height: 0))
        view.addSubview(volView)
    }

    // MARK: - CameraV3ViewInput
    
    var onViewWillAppear: ((Bool) -> ())?
    var onViewDidDisappear: ((Bool) -> ())?
    var onViewDidLayoutSubviews: (() -> ())?
    
    var onCloseButtonTap: (() -> ())? {
        get { cameraView.onCloseButtonTap }
        set { cameraView.onCloseButtonTap = newValue }
    }
    
    var onToggleCameraButtonTap: (() -> ())? {
        get { cameraView.onToggleCameraButtonTap }
        set { cameraView.onToggleCameraButtonTap = newValue }
    }
    var onFlashToggle: ((Bool) -> ())? {
        get { cameraView.onFlashToggle }
        set { cameraView.onFlashToggle = newValue }
    }
    
    var onShutterButtonTap: (() -> ())? {
        get { cameraView.onShutterButtonTap }
        set { cameraView.onShutterButtonTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { cameraView.onLastPhotoThumbnailTap }
        set { cameraView.onLastPhotoThumbnailTap = newValue }
    }
    
    var onFocusTap: ((_ focusPoint: CGPoint, _ touchPoint: CGPoint) -> Void)? {
        get { cameraView.onFocusTap }
        set { cameraView.onFocusTap = newValue }
    }
    
    var onDrawingMeasurementStop: (() -> ())? {
        get { cameraView.onDrawingMeasurementStop }
        set { cameraView.onDrawingMeasurementStop = newValue }
    }
    
    func setFlashButtonVisible(_ flag: Bool) {
        cameraView.setFlashButtonVisible(flag)
    }
    
    func setFlashButtonOn(_ flag: Bool) {
        cameraView.setFlashButtonOn(flag)
    }
    
    func animateShot() {
        cameraView.animateShot()
    }
    
    func setShutterButtonEnabled(_ flag: Bool, _ animated: Bool) {
        cameraView.setShutterButtonEnabled(flag, animated: animated)
    }
    
    func setHintText(_ text: String) {
        cameraView.setHintText(text)
    }
    
    func setSelectedData(_ viewData: SelectedPhotosViewData?, animated: Bool) {
        cameraView.setSelectedData(viewData, animated: animated)
    }
    
    func setSelectedDataEnabled(_ flag: Bool) {
        cameraView.setSelectedDataEnabled(flag)
    }
    
    func showFocus(on point: CGPoint) {
        cameraView.showFocus(on: point)
    }
    
    func setAccessDeniedViewVisible(_ flag: Bool) {
        cameraView.setAccessDeniedViewVisible(flag)
    }
    
    func setAccessDeniedTitle(_ title: String) {
        cameraView.setAccessDeniedTitle(title)
    }
    
    func setAccessDeniedMessage(_ message: String) {
        cameraView.setAccessDeniedMessage(message)
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        cameraView.setAccessDeniedButtonTitle(title)
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { cameraView.onAccessDeniedButtonTap }
        set { cameraView.onAccessDeniedButtonTap = newValue }
    }
    
    // MARK: - CameraV3ViewController
    func setTheme(_ theme: CameraV3UITheme) {
        cameraView.setTheme(theme)
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        cameraView.setPreviewLayer(previewLayer)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
