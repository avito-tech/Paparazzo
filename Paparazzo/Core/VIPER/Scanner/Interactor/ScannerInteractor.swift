import ImageSource

protocol ScannerInteractor: class {
    
    var item: MediaPickerItem? { set get }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
}
