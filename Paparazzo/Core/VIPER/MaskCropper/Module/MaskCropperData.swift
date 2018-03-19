import ImageSource

public struct MaskCropperData {
    
    public let imageSource: ImageSource
    public let cropCanvasSize: CGSize
    
    public init(
        imageSource: ImageSource,
        cropCanvasSize: CGSize = CGSize(width: 1280, height: 960))
    {
        self.imageSource = imageSource
        self.cropCanvasSize = cropCanvasSize
    }
    
}

