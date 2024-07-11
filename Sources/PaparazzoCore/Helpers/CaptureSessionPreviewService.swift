import AVFoundation
import ImageSource
import UIKit

/// Delete `@objc` when the problem in Swift will be resolved
/// https://bugs.swift.org/browse/SR-55
@objc public protocol CameraCaptureOutputHandler: AnyObject {
    var imageBuffer: CVImageBuffer? { get set }
}

final class CaptureSessionPreviewService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - CaptureSessionPreviewService
    @discardableResult
    static func startStreamingPreview(
        of captureSession: AVCaptureSession,
        to handler: CameraCaptureOutputHandler,
        isMirrored: Bool = false)
        -> DispatchQueue
    {
        return service(for: captureSession, isMirrored: isMirrored).startStreamingPreview(to: handler)
    }
    
    func startStreamingPreview(to handler: CameraCaptureOutputHandler) -> DispatchQueue {
        queue.async { [weak self] in
            self?.handlers.append(WeakWrapper(value: handler))
        }
        return queue
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    @objc func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection)
    {
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), !isInBackground {
            handlers.forEach { handlerWrapper in
                handlerWrapper.value?.imageBuffer = imageBuffer
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
    private var handlers = [WeakWrapper<CameraCaptureOutputHandler>]()
    private var isInBackground = false
    private var synchronizer: CaptureSessionSynchronizer?
    
    private init(captureSession: AVCaptureSession, isMirrored: Bool) {
        super.init()
        
        subscribeForAppStateChangeNotifications()
        setUpVideoDataOutput(for: captureSession, isMirrored: isMirrored)
    }
    
    private static func service(for captureSession: AVCaptureSession, isMirrored: Bool) -> CaptureSessionPreviewService {
        if let service = sharedServices.object(forKey: captureSession) {
            return service
        } else {
            let service = CaptureSessionPreviewService(captureSession: captureSession, isMirrored: isMirrored)
            sharedServices.setObject(service, forKey: captureSession)
            return service
        }
    }
    
    private func subscribeForAppStateChangeNotifications() {
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppWillResignActive(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    private func setUpVideoDataOutput(for captureSession: AVCaptureSession, isMirrored: Bool) {
        synchronizer = CaptureSessionSynchronizer(captureSession: captureSession)
        let captureOutput = AVCaptureVideoDataOutput()
        
        // CoreImage wants BGRA pixel format
        captureOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        
        captureOutput.setSampleBufferDelegate(self, queue: queue)
        
        synchronizer?.configuration = { [weak captureSession] in
            guard let captureSession = captureSession else { return }
            if captureSession.canAddOutput(captureOutput) {
                captureSession.addOutput(captureOutput)
            }

            for connection in captureOutput.connections {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                    connection.isVideoMirrored = isMirrored
                }
            }
        }

        synchronizer?.startSynchronize()
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
