import AVFoundation

protocol CameraModuleInput: class {
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ())
    func setCameraOutputNeeded(_: Bool)
    
    func isFlashAvailable(completion: @escaping (Bool) -> ())
    func setFlashEnabled(_: Bool, completion: @escaping (_ success: Bool) -> ())
    
    func canToggleCamera(completion: @escaping (Bool) -> ())
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ())
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ())
    
    func setPreviewImagesSizeForNewPhotos(_: CGSize)
    
    func mainModuleDidAppear(animated: Bool)
}
