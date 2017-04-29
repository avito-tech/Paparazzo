public struct MaskCropperData {
    
    public let photo: MediaPickerItem
    public let cropCanvasSize: CGSize
    
    public init(
        photo: MediaPickerItem,
        cropCanvasSize: CGSize)
    {
        self.photo = photo
        self.cropCanvasSize = cropCanvasSize
    }
    
}

