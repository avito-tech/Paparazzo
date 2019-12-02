import AVFoundation
import ImageSource

public final class CameraOutputView: UIView {
    
    // MARK: - Subview
    private var cameraView: CameraOutputRenderView?
    
    // MARK: - Init
    
    public init(captureSession: AVCaptureSession, outputOrientation: ExifOrientation) {
        
        self.orientation = outputOrientation
        
        super.init(frame: .zero)
        
        let eaglContext: EAGLContext? = EAGLContext(api: .openGLES2)

        let glkView = eaglContext.flatMap { eaglContext in
            CameraOutputGLKView(
                captureSession: captureSession,
                outputOrientation: outputOrientation,
                eaglContext: eaglContext
            )
        }
        
        if let glkView = glkView {
            cameraView = glkView
            addSubview(glkView)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        cameraView?.frame = bounds
    }
    
    // MARK: - CameraOutputView
    
    public var orientation: ExifOrientation {
        didSet {
            cameraView?.orientation = orientation
        }
    }
    
    public var onFrameDraw: (() -> ())? {
        didSet {
            cameraView?.onFrameDraw = onFrameDraw
        }
    }
}
