import ImageSource

final class ScannerInteractorImpl: ScannerInteractor {
    
    private let deviceOrientationService: DeviceOrientationService
    
    init(deviceOrientationService: DeviceOrientationService) {
        self.deviceOrientationService = deviceOrientationService
    }
    
    // MARK: - ScannerInteractor
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = handler
        handler(deviceOrientationService.currentOrientation)
    }
}
