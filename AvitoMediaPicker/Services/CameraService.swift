import AVFoundation
import ImageIO

protocol CameraService: class {
    
    var captureSession: AVCaptureSession { get }
    
    var isFlashAvailable: Bool { get }
    func setFlashEnabled(enabled: Bool)
    
    func takePhoto(completion: CameraPhoto? -> ())
    func setCaptureSessionRunning(needsRunning: Bool)
}

final class CameraServiceImpl: CameraService {
    
    let captureSession = AVCaptureSession()
    private let imageResizingService: ImageResizingService
    
    private let output = AVCaptureStillImageOutput()
    private var camera: AVCaptureDevice?
    
    init(imageResizingService: ImageResizingService) {
        
        self.imageResizingService = imageResizingService
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        guard let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as? [AVCaptureDevice] else {
            // TODO: handle no video devices
            return
        }
        
        guard let camera = videoDevices.filter({ $0.position == .Back }).first else {
            return
        }
        
        self.camera = camera
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                // TODO: handle failure
            }
            
        } catch let error as NSError {
            print(error)
            // TODO: handle failure
        }
        
        output.outputSettings = [
            AVVideoCodecKey: AVVideoCodecJPEG
        ]
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        } else {
            // TODO: handle failure
        }
        
        captureSession.startRunning()
    }
    
    // MARK: - CameraInteractor
    
    func setCaptureSessionRunning(needsRunning: Bool) {
        if needsRunning {
            captureSession.startRunning()
        } else {
            captureSession.stopRunning()
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

    func takePhoto(completion: CameraPhoto? -> ()) {
        guard let connection = videoOutputConnection() else {
            // TODO
            return
        }
        
        output.captureStillImageAsynchronouslyFromConnection(connection) { [weak self] sampleBuffer, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { [weak self] in
          
                let exifAttachments = CMGetAttachment(
                    sampleBuffer,
                    kCGImagePropertyExifDictionary,
                    UnsafeMutablePointer<CMAttachmentMode>(nil))
                
                print(exifAttachments)
                
                if let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer) {
                    
                    let randomId: NSString = NSUUID().UUIDString
                    let tempDirPath: NSString = NSTemporaryDirectory()
                    
                    guard let tempName = randomId.stringByAppendingPathExtension("jpg"),
                        thumbnailName = NSString(string: "\(randomId)-thumbnail").stringByAppendingPathExtension("jpg")
                    else {
                        return  // TODO
                    }
                    
                    let filePath = tempDirPath.stringByAppendingPathComponent(tempName)
                    let thumbnailPath = tempDirPath.stringByAppendingPathComponent(thumbnailName)
                    
                    let thumbnailSize = CGSize(width: 200, height: 200)
                    
                    data.writeToFile(filePath, atomically: true)
                    
                    self?.imageResizingService.resizeImage(atPath: filePath, toSize: thumbnailSize, outputPath: thumbnailPath) { success in
                        completion(CameraPhoto(
                            url: NSURL(fileURLWithPath: filePath, isDirectory: false),
                            thumbnailUrl: NSURL(fileURLWithPath: thumbnailPath, isDirectory: false)
                        ))
                    }
                }
                
                // TODO: handle error cases
            }
        }
    }
    
    // MARK: - Private
    
    private func videoOutputConnection() -> AVCaptureConnection? {
        
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

struct PhotoFromCamera: AbstractImage {
    
    let url: NSURL
    
    private let imageResizingService: ImageResizingService
    
    init(url: NSURL, imageResizingService: ImageResizingService) {
        self.url = url
        self.imageResizingService = imageResizingService
    }
    
    // MARK: - AbstractImage
    
    func fullResolutionImage<T : InitializableWithCGImage>(completion: T? -> ()) {
        // TODO
    }
    
    func imageFittingSize<T : InitializableWithCGImage>(size: CGSize, contentMode: AbstractImageContentMode, completion: T? -> ()) {
        // TODO
    }
}
