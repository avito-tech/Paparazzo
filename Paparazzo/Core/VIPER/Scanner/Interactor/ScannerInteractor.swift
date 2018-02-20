import ImageSource

protocol ScannerInteractor: class {
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters)
}
