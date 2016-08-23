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
    
    private let glkView: SelfBindingGLKView
    private let eaglContext: EAGLContext
    private let ciContext: CIContext
    
    init(captureSession: AVCaptureSession, outputOrientation: ExifOrientation) {
        
        eaglContext = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(eaglContext)
        
        ciContext = CIContext(EAGLContext: eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
        
        glkView = SelfBindingGLKView(frame: .zero, context: eaglContext)
        glkView.enableSetNeedsDisplay = false
        
        self.orientation = outputOrientation
        
        setUpWithAVCaptureSession(captureSession)
    }
    
    deinit {
        if EAGLContext.currentContext() === eaglContext {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    private func setUpWithAVCaptureSession(session: AVCaptureSession) {
        
        let delegate = CameraOutputGLKBinderDelegate.sharedInstance
        
        dispatch_async(delegate.queue) {
            
            delegate.binders.append(WeakWrapper(value: self))
            
            let output = AVCaptureVideoDataOutput()
            // CoreImage wants BGRA pixel format
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
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

private final class SelfBindingGLKView: GLKView {
    
    var drawableBounds: CGRect = .zero
    
    deinit {
        deleteDrawable()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.size.width > 0 && bounds.size.height > 0 {
            bindDrawable()
            drawableBounds = CGRect(x: 0, y: 0, width: drawableWidth, height: drawableHeight)
        }
    }
}

private final class CameraOutputGLKBinderDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    static let sharedInstance = CameraOutputGLKBinderDelegate()
    
    let queue = dispatch_queue_create("ru.avito.MediaPicker.CameraOutputGLKBinder.queue", nil)
    
    var binders = [WeakWrapper<CameraOutputGLKBinder>]()
    var isInBackground = false
    
    override init() {
        super.init()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppWillResignActive(_:)),
            name: UIApplicationWillResignActiveNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive(_:)),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func handleAppWillResignActive(_: NSNotification) {
        glFinish()
        isInBackground = true
    }
    
    @objc private func handleAppDidBecomeActive(_: NSNotification) {
        isInBackground = false
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    @objc func captureOutput(
        captureOutput: AVCaptureOutput?,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer?,
        fromConnection connection: AVCaptureConnection?
    ) {
        guard let imageBuffer = sampleBuffer.flatMap({ CMSampleBufferGetImageBuffer($0) }) else { return }
        
        for binderWrapper in binders {
            if let binder = binderWrapper.value {
                drawImageBuffer(imageBuffer, binder: binder)
            }
        }
    }
    
    // MARK: - Private
    
    private func drawImageBuffer(imageBuffer: CVImageBuffer, binder: CameraOutputGLKBinder) {
        
        // After your app exits its applicationDidEnterBackground: method, it must not make any new OpenGL ES calls.
        // If it makes an OpenGL ES call, it is terminated by iOS.
        guard !isInBackground else { return }
        
        let view = binder.glkView
        let ciContext = binder.ciContext
        
        guard view.drawableBounds.size.width > 0 && view.drawableBounds.size.height > 0 else {
            return
        }
        
        let orientation = Int32(binder.orientation.rawValue)

        let sourceImage = CIImage(CVPixelBuffer: imageBuffer).imageByApplyingOrientation(orientation)
        var sourceExtent = sourceImage.extent
        
        let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
        let previewAspect = view.drawableBounds.size.width  / view.drawableBounds.size.height
        
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
        
        ciContext.drawImage(sourceImage, inRect: view.drawableBounds, fromRect: drawRect)
        
        view.display()
    }
}