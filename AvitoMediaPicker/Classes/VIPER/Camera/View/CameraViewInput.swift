protocol CameraViewInput: class {
    
    func setOutputParameters(_: CameraOutputParameters)
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    // MARK: - Callbacks from main module
    func mainModuleDidAppear(animated: Bool)
    func adjustForDeviceOrientation(_: DeviceOrientation)
}
