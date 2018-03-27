import ImageSource

final class ScannerInteractorImpl: ScannerInteractor {
    
    // MARK: - Dependencies
    
    private let deviceOrientationService: DeviceOrientationService
    
    // MARK: - Properties
    
    private var cameraCaptureOutputHandlers = [WeakWrapper<ScannerOutputHandler>]()
    
    // MARK: - Init
    
    init(
        deviceOrientationService: DeviceOrientationService,
        cameraCaptureOutputHandlers: [ScannerOutputHandler])
    {
        self.deviceOrientationService = deviceOrientationService
        self.cameraCaptureOutputHandlers = cameraCaptureOutputHandlers.map { WeakWrapper(value: $0) }
    }
    
    // MARK: - ScannerInteractor
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = { [weak self] orientation in
            self?.cameraCaptureOutputHandlers.forEach {
                if let outputHandler = $0.value {
                    outputHandler.orientation = orientation.toCGImagePropertyOrientation().rawValue
                }
            }
            
            handler(orientation)
        }
        
        handler(deviceOrientationService.currentOrientation)
    }
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters) {
        cameraCaptureOutputHandlers.forEach {
            if let handler = $0.value {
                CaptureSessionPreviewService.startStreamingPreview(of: parameters.captureSession, to: handler)
            }
        }
    }
}

extension DeviceOrientation {
    func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .portrait:
            return .right
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        case .portraitUpsideDown:
            return .left
        case .unknown:
            return .left
        }
    }
    
}
