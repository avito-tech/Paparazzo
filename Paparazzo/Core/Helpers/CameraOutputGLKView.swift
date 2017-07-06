import AVFoundation
import GLKit
import ImageSource

final class CameraOutputGLKView: GLKView {
    
    // MARK: - Init
    
    init(captureSession: AVCaptureSession, outputOrientation: ExifOrientation, eaglContext: EAGLContext) {
        
        ciContext = CIContext(eaglContext: eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
        orientation = outputOrientation
        
        super.init(frame: .zero, context: eaglContext)
        
        clipsToBounds = true
        enableSetNeedsDisplay = false
        
        CaptureSessionPreviewService.startStreamingPreview(of: captureSession, to: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CameraOutputView
    
    var orientation: ExifOrientation
    var onFrameDraw: (() -> ())?
    
    var imageBuffer: CVImageBuffer? {
        didSet {
            display()
        }
    }
    
    // MARK: - GLKView
    
    override func draw(_ rect: CGRect) {
        guard let imageBuffer = imageBuffer else { return }
        
        let image = CIImage(cvPixelBuffer: imageBuffer).applyingOrientation(Int32(orientation.rawValue))
        
        ciContext.draw(
            image,
            in: drawableBounds(for: rect),
            from: sourceRect(of: image, targeting: rect)
        )
        
        onFrameDraw?()
    }
    
    // MARK: - Private
    
    private let ciContext: CIContext
    
    private func drawableBounds(for rect: CGRect) -> CGRect {
        
        let screenScale = UIScreen.main.nativeScale
        
        var drawableBounds = rect
        drawableBounds.size.width *= screenScale
        drawableBounds.size.height *= screenScale
        
        return drawableBounds
    }
    
    private func sourceRect(of image: CIImage, targeting rect: CGRect) -> CGRect {
        guard image.extent.width > 0, image.extent.height > 0, rect.width > 0, rect.height > 0 else {
            return .zero
        }
        
        let sourceExtent = image.extent
        
        let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
        let previewAspect = rect.size.width  / rect.size.height
        
        // we want to maintain the aspect radio of the screen size, so we clip the video image
        var drawRect = sourceExtent
        
        if sourceAspect > previewAspect {
            // use full height of the video image, and center crop the width
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2
            drawRect.size.width = drawRect.size.height * previewAspect
        } else {
            // use full width of the video image, and center crop the height
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2
            drawRect.size.height = drawRect.size.width / previewAspect
        }
        
        return drawRect
    }
}
