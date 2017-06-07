import AVFoundation

final class CaptureSessionPreviewService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - CaptureSessionPreviewService
    
    static func startStreamingPreview(of captureSession: AVCaptureSession, to view: CameraOutputGLKView) {
        service(for: captureSession).startStreamingPreview(to: view)
    }
    
    func startStreamingPreview(to view: CameraOutputGLKView) {
        queue.async { [weak self] in
            self?.views.append(WeakWrapper(value: view))
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    @objc func captureOutput(
        _ captureOutput: AVCaptureOutput?,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer?,
        from connection: AVCaptureConnection?)
    {
        if let imageBuffer = sampleBuffer.flatMap({ CMSampleBufferGetImageBuffer($0) }), !isInBackground {
            views.forEach { viewWrapper in
                viewWrapper.value?.imageBuffer = imageBuffer
            }
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    
    private static var sharedServices = NSMapTable<AVCaptureSession, CaptureSessionPreviewService>.weakToStrongObjects()
    
    private let queue = DispatchQueue(label: "ru.avito.AvitoMediaPicker.CaptureSessionPreviewService.queue")
    private var views = [WeakWrapper<CameraOutputGLKView>]()
    private var isInBackground = false
    
    private init(captureSession: AVCaptureSession) {
        super.init()
        
        subscribeForAppStateChangeNotifications()
        setUpVideoDataOutput(for: captureSession)
    }
    
    private static func service(for captureSession: AVCaptureSession) -> CaptureSessionPreviewService {
        if let service = sharedServices.object(forKey: captureSession) {
            return service
        } else {
            let service = CaptureSessionPreviewService(captureSession: captureSession)
            sharedServices.setObject(service, forKey: captureSession)
            return service
        }
    }
    
    private func subscribeForAppStateChangeNotifications() {
        
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
    
    private func setUpVideoDataOutput(for captureSession: AVCaptureSession) {
        
        let captureOutput = AVCaptureVideoDataOutput()
        
        // CoreImage wants BGRA pixel format
        captureOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        
        captureOutput.setSampleBufferDelegate(self, queue: queue)
        
        do {
            try captureSession.configure {
                if captureSession.canAddOutput(captureOutput) {
                    captureSession.addOutput(captureOutput)
                }
            }
        } catch {
            debugPrint("Couldn't configure AVCaptureSession: \(error)")
        }
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
}
