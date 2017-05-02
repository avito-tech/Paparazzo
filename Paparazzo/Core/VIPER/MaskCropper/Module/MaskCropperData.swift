import ImageSource

public struct MaskCropperData {
    
    public let imageSource: ImageSource
    public let cropCanvasSize: CGSize
    
    public init(
        imageSource: ImageSource,
        cropCanvasSize: CGSize)
    {
        self.imageSource = imageSource
        self.cropCanvasSize = cropCanvasSize
    }
    
}

