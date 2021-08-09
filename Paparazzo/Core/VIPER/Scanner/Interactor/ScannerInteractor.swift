import ImageSource

protocol ScannerInteractor: AnyObject {
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters)
}
