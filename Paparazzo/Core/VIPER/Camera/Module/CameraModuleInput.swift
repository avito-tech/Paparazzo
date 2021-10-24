import ImageSource

protocol CameraModuleInput: AnyObject {
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ())
    func setCameraOutputNeeded(_: Bool)
    
    func isFlashAvailable(completion: @escaping (Bool) -> ())
    func isFlashEnabled(completion: @escaping (Bool) -> ())
    func setFlashEnabled(_: Bool, completion: ((_ success: Bool) -> ())?)
    
    func canToggleCamera(completion: @escaping (Bool) -> ())
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ())
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ())
    
    func setPreviewImagesSizeForNewPhotos(_: CGSize)
    
    func mainModuleDidAppear(animated: Bool)
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    func setTitle(_: String)
    func setSubtitle(_: String)
    func setCameraHintVisible(_: Bool)
    func setCameraHint(text: String)
}
