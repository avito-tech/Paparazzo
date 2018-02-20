import ImageSource

final class ScannerInteractorImpl: ScannerInteractor {
    
    // MARK: - Dependencies
    
    private let deviceOrientationService: DeviceOrientationService
    
    // MARK: - Properties
    
    private var cameraCaptureOutputHandlers = [ScannerOutputHandler]()
    
    // MARK: - Init
    
    init(
        deviceOrientationService: DeviceOrientationService,
        cameraCaptureOutputHandlers: [ScannerOutputHandler])
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
            $0.orientation = CGImagePropertyOrientation(rawValue: UInt32(parameters.orientation.rawValue))
            CaptureSessionPreviewService.startStreamingPreview(of: parameters.captureSession, to: $0)
        }
    }
}
