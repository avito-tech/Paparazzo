import Foundation
import CoreImage
import OpenGLES
import GLKit
import AVFoundation

// Штука, которая рендерит аутпут AVCaptureSession в UIView (в данной конкретной реализации — в GLKView)
// Решение взято отсюда: http://stackoverflow.com/questions/16543075/avcapturesession-with-multiple-previews
final class CameraOutputGLKBinder {
    
    var orientation: ExifOrientation
    
    var view: UIView {
        return glkView
    }
    
    fileprivate let glkView: CameraOutputView
    fileprivate let eaglContext: EAGLContext
    fileprivate let ciContext: CIContext
    
    var onFrameDrawn: (() -> ())?
    
    init(captureSession: AVCaptureSession, outputOrientation: ExifOrientation) {
        
        eaglContext = EAGLContext(api: .openGLES2)
        
        ciContext = CIContext(eaglContext: eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
        
        glkView = CameraOutputView(frame: .zero, context: eaglContext)
        glkView.enableSetNeedsDisplay = false
        
        self.orientation = outputOrientation
        
        setUpWithAVCaptureSession(captureSession)
        
        glkView.binder = self
    }
    
    private func setUpWithAVCaptureSession(_ session: AVCaptureSession) {
        
        let delegate = CameraOutputGLKBinderDelegate.sharedInstance
        
        delegate.queue.async {
            
            delegate.binders.append(WeakWrapper(value: self))
            
            let output = AVCaptureVideoDataOutput()
            // CoreImage wants BGRA pixel format
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCVPixelFormatType_32BGRA)
            ]
            output.setSampleBufferDelegate(delegate, queue: delegate.queue)
            
            do {
                try session.configure {
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    }
                }
            } catch {
                debugPrint("Couldn't configure AVCaptureSession: \(error)")
            }
        }
    }
}

private final class CameraOutputGLKBinderDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    static let sharedInstance = CameraOutputGLKBinderDelegate()
    
    let queue = DispatchQueue(label: "ru.avito.MediaPicker.CameraOutputGLKBinder.queue")
    
    var binders = [WeakWrapper<CameraOutputGLKBinder>]()
    var isInBackground = false
    
    override init() {
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppWillResignActive(_:)),
            name: .UIApplicationWillResignActive,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive(_:)),
            name: .UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleAppWillResignActive(_: NSNotification) {
        // Синхронно, потому что после выхода из этого метода не должно быть никаких обращений к OpenGL
        // (флаг isInBackground проверяется в очереди `queue`)
        queue.sync {
            glFinish()
            self.isInBackground = true
        }
    }
    
    @objc private func handleAppDidBecomeActive(_: NSNotification) {
        queue.async {
            self.isInBackground = false
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    @objc func captureOutput(
        _ captureOutput: AVCaptureOutput?,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer?,
        from connection: AVCaptureConnection?)
    {
        guard let imageBuffer = sampleBuffer.flatMap({ CMSampleBufferGetImageBuffer($0) }) else { return }
        
        for binderWrapper in binders {
            if let binder = binderWrapper.value {
                drawImageBuffer(imageBuffer, binder: binder)
            }
        }
    }
    
    // MARK: - Private
    
    private func drawImageBuffer(_ imageBuffer: CVImageBuffer, binder: CameraOutputGLKBinder) {
        
        // After your app exits its applicationDidEnterBackground: method, it must not make any new OpenGL ES calls.
        // If it makes an OpenGL ES call, it is terminated by iOS.
        guard !isInBackground else { return }
        
        binder.glkView.imageBuffer = imageBuffer
        binder.glkView.display()
    }
}

private final class CameraOutputView: GLKView {
    
    weak var binder: CameraOutputGLKBinder?
    var imageBuffer: CVImageBuffer?
    
    override func draw(_ rect: CGRect) {
        
        guard let binder = binder, let imageBuffer = imageBuffer else {
            return
        }
        
        let ciContext = binder.ciContext
        
        let orientation = Int32(binder.orientation.rawValue)
        
        let screenScale = UIScreen.main.scale
        
        var drawableBounds = rect
        drawableBounds.size.width *= screenScale
        drawableBounds.size.height *= screenScale
        
        let sourceImage = CIImage(cvPixelBuffer: imageBuffer).applyingOrientation(orientation)
        let sourceExtent = sourceImage.extent
        
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
        
        // clear eagl view to grey
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // set the blend mode to "source over" so that CI will use that
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        ciContext.draw(sourceImage, in: drawableBounds, from: drawRect)
        
        binder.onFrameDrawn?()
    }
}
