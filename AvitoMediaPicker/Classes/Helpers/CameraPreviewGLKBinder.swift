import Foundation
import CoreImage
import OpenGLES
import GLKit
import AVFoundation

// Штука, которая рендерит аутпут AVCaptureSession в UIView (в данной конкретной реализации — в GLKView)
// Решение взято отсюда: http://stackoverflow.com/questions/16543075/avcapturesession-with-multiple-previews
final class CameraOutputGLKBinder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let view: GLKView
    private var viewBounds: CGRect = .zero
    
    private let eaglContext: EAGLContext
    private let ciContext: CIContext
    private let queue = dispatch_queue_create("ru.avito.MediaPicker.CameraOutputGLKBinder.queue", nil)
    
    override init() {
        
        eaglContext = EAGLContext(API: .OpenGLES2)
        EAGLContext.setCurrentContext(eaglContext)
        
        ciContext = CIContext(EAGLContext: eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
        
        view = GLKView(frame: .zero, context: eaglContext)
        
        super.init()
    }
    
    deinit {
        if EAGLContext.currentContext() == eaglContext {
            EAGLContext.setCurrentContext(nil)
        }
    }
    
    func setUpWithAVCaptureSession(session: AVCaptureSession) -> UIView {
        
        dispatch_async(queue) {
            
            let output = AVCaptureVideoDataOutput()
            // CoreImage wants BGRA pixel format
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)]
            output.setSampleBufferDelegate(self, queue: self.queue)
            
            do {
                try session.configure {
                    if session.canAddOutput(output) {
                        session.addOutput(output)
                    }
                }
            } catch {
                print("Couldn't configure AVCaptureSession: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.configureView()
            }
        }
        
        return view
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(
        captureOutput: AVCaptureOutput?,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer?,
        fromConnection connection: AVCaptureConnection?
    ) {
        guard let imageBuffer = sampleBuffer.flatMap({ CMSampleBufferGetImageBuffer($0) }) else { return }
        
        let sourceImage = CIImage(CVPixelBuffer: imageBuffer)
        let sourceExtent = sourceImage.extent
        
        let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
        let previewAspect = viewBounds.size.width  / viewBounds.size.height
        
        // we want to maintain the aspect radio of the screen size, so we clip the video image
        var drawRect = sourceExtent
        
        if (sourceAspect > previewAspect) {
            // use full height of the video image, and center crop the width
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0
            drawRect.size.width = drawRect.size.height * previewAspect
        } else {
            // use full width of the video image, and center crop the height
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0
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
    
    // MARK: - Private
    
    func configureView() {
        
        view.enableSetNeedsDisplay = false
        
        // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right),
        // we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view;
        // if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror),
        // you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
        view.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        
        // bind the frame buffer to get the frame buffer width and height;
        // the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
        // hence the need to read from the frame buffer's width and height;
        // in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
        // we want to obtain this piece of information so that we won't be
        // accessing _videoPreviewView's properties from another thread/queue
        view.bindDrawable()
        
        viewBounds = CGRect(x: 0, y: 0, width: view.drawableWidth, height: view.drawableHeight)
        
        dispatch_async(dispatch_get_main_queue()) { [view] in
            let transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            
            view.transform = transform
            view.frame = view.frame
        }
    }
}
