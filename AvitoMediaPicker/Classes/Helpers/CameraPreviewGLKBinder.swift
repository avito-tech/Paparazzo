import Foundation
import CoreImage
import OpenGLES
import GLKit
import AVFoundation

// Штука, которая рендерит аутпут AVCaptureSession в UIView (в данной конкретной реализации — в GLKView)
// Решение взято отсюда: http://stackoverflow.com/questions/16543075/avcapturesession-with-multiple-previews
final class CameraOutputGLKBinder {
    
    private let view: GLKView
    private var viewBounds: CGRect = .zero
    
    private let eaglContext: EAGLContext
    private let ciContext: CIContext
    
    init() {
        
        eaglContext = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(eaglContext)
        
        ciContext = CIContext(EAGLContext: eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
        
        view = GLKView(frame: .zero, context: eaglContext)
    }
    
    deinit {
        if EAGLContext.currentContext() === eaglContext {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    func setUpWithAVCaptureSession(session: AVCaptureSession) -> UIView {
        
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
            
            dispatch_async(dispatch_get_main_queue()) {
                self.configureView()
            }
        }
        
        return view
    }
    
    // MARK: - Private
    
    func configureView() {
        
        view.enableSetNeedsDisplay = false
        
        // bind the frame buffer to get the frame buffer width and height;
        // the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
        // hence the need to read from the frame buffer's width and height;
        // in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
        // we want to obtain this piece of information so that we won't be
        // accessing _videoPreviewView's properties from another thread/queue
        view.bindDrawable()
        
        viewBounds = CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight)
    }
}

private final class CameraOutputGLKBinderDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    static let sharedInstance = CameraOutputGLKBinderDelegate()
    
    let queue = dispatch_queue_create("ru.avito.MediaPicker.CameraOutputGLKBinder.queue", nil)
    
    var binders = [WeakWrapper<CameraOutputGLKBinder>]()
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    @objc func captureOutput(
        captureOutput: AVCaptureOutput?,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer?,
        fromConnection connection: AVCaptureConnection?
    ) {
        guard let imageBuffer = sampleBuffer.flatMap({ CMSampleBufferGetImageBuffer($0) }) else { return }
        
        for binderWrapper in binders {
            if let binder = binderWrapper.value {
                drawImageBuffer(imageBuffer, viewBounds: binder.viewBounds, view: binder.view, ciContext: binder.ciContext)
            }
        }
    }
    
    // MARK: - Private
    
    private func drawImageBuffer(imageBuffer: CVImageBuffer, viewBounds: CGRect, view: GLKView, ciContext: CIContext) {
        
        let orientation = Int32(ExifOrientation.Left.rawValue)  // камера отдает картинку в этой ориентации

        let sourceImage = CIImage(CVPixelBuffer: imageBuffer).imageByApplyingOrientation(orientation)
        var sourceExtent = sourceImage.extent
        
        let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
        let previewAspect = viewBounds.size.width  / viewBounds.size.height
        
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
        
        view.bindDrawable()
        
        // clear eagl view to grey
        glClearColor(0.5, 0.5, 0.5, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        // set the blend mode to "source over" so that CI will use that
        glEnable(GLenum(GL_BLEND))
        glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        
        ciContext.drawImage(sourceImage, inRect: viewBounds, fromRect: drawRect)
        
        view.display()
    }
}