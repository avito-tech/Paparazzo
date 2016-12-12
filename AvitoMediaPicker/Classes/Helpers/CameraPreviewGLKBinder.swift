import GPUImage

final class CameraOutputGLKBinder {
    
    var view: UIView {
        return imageView
    }
    
    var onFrameDrawn: (() -> ())? {
        get { return imageView.onNewFrameReady }
        set { imageView.onNewFrameReady = newValue }
    }
    
    init(imageOutput: GPUImageOutput) {
        imageView = CameraOutputView()
        imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        imageOutput.addTarget(imageView)
    }
    
    // MARK: - Private
    private let imageView: CameraOutputView
}

private class CameraOutputView: GPUImageView {
    
    var onNewFrameReady: (() -> ())?
    
    override func newFrameReady(at frameTime: CMTime, at textureIndex: Int) {
        super.newFrameReady(at: frameTime, at: textureIndex)
        onNewFrameReady?()
    }
}
