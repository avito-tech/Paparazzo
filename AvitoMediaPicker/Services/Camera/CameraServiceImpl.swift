import AVFoundation
import ImageIO

final class CameraServiceImpl: CameraService {
    
    let captureSession: AVCaptureSession?
    
    // MARK: - Private types and properties
    
    private struct Error: ErrorType {}
    
    private let output: AVCaptureStillImageOutput?
    private let camera: AVCaptureDevice?
    
    // MARK: - Init
    
    init() {
        
        do {
            
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            
            let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice]
            let camera = videoDevices?.filter({ $0.position == .Back }).first
            
            let input = try AVCaptureDeviceInput(device: camera)
            
            let output = AVCaptureStillImageOutput()
            output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(output) {
                captureSession.addInput(input)
                captureSession.addOutput(output)
            } else {
                throw Error()
            }
            
            captureSession.startRunning()
            
            self.camera = camera
            self.output = output
            self.captureSession = captureSession
            
        } catch {
            self.camera = nil
            self.output = nil
            self.captureSession = nil
        }
    }
    
    // MARK: - CameraInteractor
    
    func setCaptureSessionRunning(needsRunning: Bool) {
        if needsRunning {
            captureSession?.startRunning()
        } else {
            captureSession?.stopRunning()
        }
    }
    
    var isFlashAvailable: Bool {
        return camera?.flashAvailable == true
    }
    
    func setFlashEnabled(enabled: Bool) -> Bool {
        
        guard let camera = camera else { return false }
        
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
        
        output.captureStillImageAsynchronouslyFromConnection(connection) { [weak self] sampleBuffer, error in
            self?.savePhoto(sampleBuffer: sampleBuffer) { photo in
                dispatch_async(dispatch_get_main_queue()) {
                    completion(photo)
                }
            }
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
    
    private func randomTemporaryPhotoFileUrl() -> NSURL? {
        
        let randomId: NSString = NSUUID().UUIDString
        let tempDirPath: NSString = NSTemporaryDirectory()
        let tempName = randomId.stringByAppendingPathExtension("jpg")
        let filePath = tempName.flatMap { tempDirPath.stringByAppendingPathComponent($0) }
        
        return filePath.flatMap { NSURL(fileURLWithPath: $0) }
    }
}