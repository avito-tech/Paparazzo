import AVFoundation

protocol CameraModuleInput: class {
    
    func getOutputParameters(completion: CameraOutputParameters? -> ())
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ())
    
    func canToggleCamera(completion: Bool -> ())
    func toggleCamera()
    
    func takePhoto(completion: MediaPickerItem? -> ())
    
    func setPreviewImagesSizeForNewPhotos(size: CGSize)
}