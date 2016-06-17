protocol CameraModuleInput: class {
    
    func setCameraOutputNeeded(isCameraOutputNeeded: Bool)
    
    func isFlashAvailable(completion: Bool -> ())
    func setFlashEnabled(enabled: Bool, completion: (success: Bool) -> ())
    
    func takePhoto(completion: MediaPickerItem? -> ())
}