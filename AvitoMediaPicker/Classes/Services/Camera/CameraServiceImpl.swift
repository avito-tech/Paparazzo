import AVFoundation
import ImageIO

final class CameraServiceImpl: CameraService {
    
    let captureSession: AVCaptureSession?
    
    // MARK: - Private types and properties
    
    private struct Error: ErrorType {}
    
    private let output: AVCaptureStillImageOutput?
    private let backCamera: AVCaptureDevice?
    private let frontCamera: AVCaptureDevice?
    private var activeCamera: AVCaptureDevice?

    // MARK: - Init
    
    init() {
        
        do {
            
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            
            let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice]
            
            let backCamera = videoDevices?.filter({ $0.position == .Back }).first
            try CameraServiceImpl.configureCamera(backCamera)
            
            let frontCamera = videoDevices?.filter({ $0.position == .Front }).first

            let input = try AVCaptureDeviceInput(device: backCamera)
            
            let output = AVCaptureStillImageOutput()
            output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(output) {
                captureSession.addInput(input)
                captureSession.addOutput(output)
            } else {
                throw Error()
            }
            
            captureSession.startRunning()
            
            self.frontCamera = frontCamera
            self.backCamera = backCamera
            self.activeCamera = backCamera
            self.output = output
            self.captureSession = captureSession
            
        } catch {
            self.frontCamera = nil
            self.backCamera = nil
            self.output = nil
            self.captureSession = nil
        }
    }
    
    // MARK: - CameraService
    
    func setCaptureSessionRunning(needsRunning: Bool) {
        if needsRunning {
            captureSession?.startRunning()
        } else {
            captureSession?.stopRunning()
        }
    }
    
    func canToggleCamera(completion: Bool -> ()) {
        completion(frontCamera != nil && backCamera != nil)
    }
    
    func toggleCamera() {
        
        guard let captureSession = captureSession else { return }
        
        do {
        
            let targetCamera = (activeCamera == backCamera) ? frontCamera : backCamera
            let newInput = try AVCaptureDeviceInput(device: targetCamera)
            
            try captureSession.configure {
                
                let currentInputs = captureSession.inputs as? [AVCaptureInput]
                currentInputs?.forEach { captureSession.removeInput($0) }
                
                // Always reset preset before testing canAddInput because preset will cause it to return NO
                captureSession.sessionPreset = AVCaptureSessionPresetHigh
                
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                }
                
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                
                try CameraServiceImpl.configureCamera(targetCamera)
            }
            
            activeCamera = targetCamera

        } catch {
            debugPrint("Couldn't toggle camera: \(error)")
        }
    }
    
    var isFlashAvailable: Bool {
        return backCamera?.flashAvailable == true
    }
    
    func setFlashEnabled(enabled: Bool) -> Bool {
        
        guard let camera = backCamera else { return false }
        
        do {
            try camera.lockForConfiguration()
            camera.flashMode = enabled ? .On : .Off
            camera.unlockForConfiguration()
            
            return true
            
        } catch {
            return false
        }
    }
    
    func takePhoto(completion: PhotoFromCamera? -> ()) {
        
        guard let output = output, connection = videoOutputConnection() else {
            completion(nil)
            return
        }
        
        if connection.supportsVideoOrientation {
            connection.videoOrientation = avOrientationForCurrentDeviceOrientation()
        }
        
        output.captureStillImageAsynchronouslyFromConnection(connection) { [weak self] sampleBuffer, error in
            self?.savePhoto(sampleBuffer: sampleBuffer) { photo in
                dispatch_async(dispatch_get_main_queue()) {
                    completion(photo)
                }
            }
        }
    }
    
    private func avOrientationForCurrentDeviceOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.currentDevice().orientation {
        case .Portrait:
            return .Portrait
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        case .LandscapeLeft:        // да-да
            return .LandscapeRight  // все именно так
        case .LandscapeRight:       // иначе получаются перевертыши
            return .LandscapeLeft   // rotation is hard on iOS (c)
        default:
            return .Portrait
        }
    }
    
    // MARK: - Private
    
    private func savePhoto(sampleBuffer sampleBuffer: CMSampleBuffer?, completion: PhotoFromCamera? -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [weak self] in
            
            if let sampleBuffer = sampleBuffer,
                url = self?.randomTemporaryPhotoFileUrl(),
                data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) {
                
                data.writeToURL(url, atomically: true)
                
                completion(PhotoFromCamera(url: url))
                
            } else {
                completion(nil)
            }
        }
    }
    
    private func videoOutputConnection() -> AVCaptureConnection? {
        
        guard let output = output else { return nil }
        
        for connection in output.connections {
            
            if let connection = connection as? AVCaptureConnection,
                inputPorts = connection.inputPorts as? [AVCaptureInputPort] {
                
                let connectionContainsVideoPort = inputPorts.filter({ $0.mediaType == AVMediaTypeVideo }).count > 0
                
                if connectionContainsVideoPort {
                    return connection
                }
            }
        }
        
        return nil
    }
    
    private static func configureCamera(camera: AVCaptureDevice?) throws {
        try camera?.lockForConfiguration()
        camera?.subjectAreaChangeMonitoringEnabled = true
        camera?.unlockForConfiguration()
    }
    
    private func randomTemporaryPhotoFileUrl() -> NSURL? {
        
        let randomId: NSString = NSUUID().UUIDString
        let tempDirPath: NSString = NSTemporaryDirectory()
        let tempName = randomId.stringByAppendingPathExtension("jpg")
        let filePath = tempName.flatMap { tempDirPath.stringByAppendingPathComponent($0) }
        
        return filePath.flatMap { NSURL(fileURLWithPath: $0) }
    }
}