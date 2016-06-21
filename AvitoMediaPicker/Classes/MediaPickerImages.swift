public struct MediaPickerImages {
    
    public var removePhotoIcon = MediaPickerImages.imageNamed("delete")
    public var cropPhotoIcon = MediaPickerImages.imageNamed("crop")
    public var returnToCameraIcon = MediaPickerImages.imageNamed("camera")
    
    public var flashOnIcon = MediaPickerImages.imageNamed("light_on")
    public var flashOffIcon = MediaPickerImages.imageNamed("light_off")
    public var cameraToggleIcon = MediaPickerImages.imageNamed("back_front")
    
    // MARK: - Private
    
    private class BundleId {}
    
    private static func imageNamed(name: String) -> () -> UIImage? {
        return {
            let bundle = NSBundle(forClass: BundleId.self)
            return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
        }
    }
}