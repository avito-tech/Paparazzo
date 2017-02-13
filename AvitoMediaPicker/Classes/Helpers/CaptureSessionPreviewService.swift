import AVFoundation

final class CaptureSessionPreviewService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - CaptureSessionPreviewService
    
    static func startStreamingPreview(of captureSession: AVCaptureSession, to view: CameraOutputView) {
        service(for: captureSession).startStreamingPreview(to: view)
    }
    
    func startStreamingPreview(to view: CameraOutputView) {
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
        guard let imageBuffer = sampleBuffer.flatMap({ CMSampleBufferGetImageBuffer($0) }) else { return }
        
        for viewWrapper in views {
            if let view = viewWrapper.value {
                drawImageBuffer(imageBuffer, in: view)
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
    private var views = [WeakWrapper<CameraOutputView>]()
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
    
    private func drawImageBuffer(_ imageBuffer: CVImageBuffer, in view: CameraOutputView) {
        
        // After your app exits its applicationDidEnterBackground: method, it must not make any new OpenGL ES calls.
        // If it makes an OpenGL ES call, it is terminated by iOS.
        guard !isInBackground else { return }
        
        view.imageBuffer = imageBuffer
        view.display()
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
