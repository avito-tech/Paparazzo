import AVFoundation
import ImageIO

protocol CameraService: class {
    
    // Will be nil after service initialization if back camera is not available
    var captureSession: AVCaptureSession? { get }
    
    var isFlashAvailable: Bool { get }
    func setFlashEnabled(enabled: Bool)
    
    func takePhoto(completion: PhotoFromCamera? -> ())
    func setCaptureSessionRunning(needsRunning: Bool)
}

struct PhotoFromCamera {
    let url: NSURL
}

final class CameraServiceImpl: CameraService {
    
    private struct Error: ErrorType {}
    
    let captureSession: AVCaptureSession?

    private let output: AVCaptureStillImageOutput?
    private var camera: AVCaptureDevice?
    
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

    func setFlashEnabled(enabled: Bool) {
        // TODO: возвращать результат: если не удалось включить вспышку, в UI не должно отображаться, как будто она включена
        do {
            try camera?.lockForConfiguration()
            camera?.flashMode = enabled ? .On : .Off
            camera?.unlockForConfiguration()
        } catch {
            print("Failed to lock camera to set flashMode")
        }
    }

    func takePhoto(completion: PhotoFromCamera? -> ()) {
        guard let output = output, connection = videoOutputConnection() else {
            // TODO
            return
        }
        
        output.captureStillImageAsynchronouslyFromConnection(connection) { sampleBuffer, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
          
                let exifAttachments = CMGetAttachment(
                    sampleBuffer,
                    kCGImagePropertyExifDictionary,
                    UnsafeMutablePointer<CMAttachmentMode>(nil))
                
                print(exifAttachments)
                
                if let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) {
                    
                    let randomId: NSString = NSUUID().UUIDString
                    let tempDirPath: NSString = NSTemporaryDirectory()
                    
                    if let tempName = randomId.stringByAppendingPathExtension("jpg") {
                        
                        let filePath = tempDirPath.stringByAppendingPathComponent(tempName)
                        let fileUrl = NSURL(fileURLWithPath: filePath)
                        
                        data.writeToFile(filePath, atomically: true)
                        
                        completion(PhotoFromCamera(url: fileUrl))
                        
                    } else {
                        completion(nil)
                    }
                }
                
                // TODO: handle error cases
            }
        }
    }
    
    // MARK: - Private
    
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
}