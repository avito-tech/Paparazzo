import ImageSource

final class ScannerInteractorImpl: ScannerInteractor {
    
    // MARK: - Dependencies
    
    private let deviceOrientationService: DeviceOrientationService
    
    // MARK: - Properties
    
    private var cameraCaptureOutputHandlers = [CameraCaptureOutputHandler]()
    
    // MARK: - Init
    
    init(
        deviceOrientationService: DeviceOrientationService,
        cameraCaptureOutputHandlers: [CameraCaptureOutputHandler])
    {
        self.deviceOrientationService = deviceOrientationService
        self.cameraCaptureOutputHandlers = cameraCaptureOutputHandlers
    }
    
    // MARK: - ScannerInteractor
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = handler
        handler(deviceOrientationService.currentOrientation)
    }
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters) {
        cameraCaptureOutputHandlers.forEach {
            CaptureSessionPreviewService.startStreamingPreview(of: parameters.captureSession, to: $0)
        }
    }
}
