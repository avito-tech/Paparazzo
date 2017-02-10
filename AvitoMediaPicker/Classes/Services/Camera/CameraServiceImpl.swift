import AVFoundation
import ImageIO
import ImageSource
import GPUImage

final class CameraServiceImpl: CameraService {
    
    // MARK: - Private types and properties
    
    private struct Error: Swift.Error {}
    
    private var cameraOutput: GPUImageStillCamera?
    private var output: AVCaptureStillImageOutput?
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var activeCamera: AVCaptureDevice?

    // MARK: - Init
    
    init() {
        let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice]
        
        backCamera = videoDevices?.filter({ $0.position == .back }).first
        frontCamera = videoDevices?.filter({ $0.position == .front }).first
    }
    
    func getImageOutput(completion: @escaping (GPUImageOutput?) -> ()) {
        
        if let cameraOutput = cameraOutput {
            completion(cameraOutput)
        
        } else {
            
            let mediaType = AVMediaTypeVideo
            
            switch AVCaptureDevice.authorizationStatus(forMediaType: mediaType) {
                
            case .authorized:
                setUpCameraOutput()
                completion(cameraOutput)
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: mediaType) { [weak self] granted in
                    if granted {
                        self?.setUpCameraOutput()
                        completion(self?.cameraOutput)
                    } else {
                        completion(nil)
                    }
                }

            case .restricted, .denied:
                completion(nil)
            }
        }
    }
    
    func getOutputOrientation(completion: @escaping (ExifOrientation) -> ()) {
        completion(outputOrientationForCamera(activeCamera))
    }
    
    func startCapture() {
        cameraOutput?.resumeCameraCapture()
    }
    
    func stopCapture() {
        cameraOutput?.pauseCapture()
    }
    
    private let cameraOutputQueue = DispatchQueue(label: "ru.avito.CameraServiceImpl.cameraOutputQueue")
    
    private func setUpCameraOutput() {
        
        #if arch(i386) || arch(x86_64)
            // Preventing crash in simulator
            return
        #endif
        
        cameraOutputQueue.sync {
            
            guard cameraOutput == nil else {
                return
            }
            
            cameraOutput = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetPhoto, cameraPosition: .back)
            cameraOutput?.horizontallyMirrorFrontFacingCamera = true
            cameraOutput?.outputImageOrientation = .portrait
            cameraOutput?.startCapture()
            
            output = cameraOutput?.captureSession.outputs.flatMap { $0 as? AVCaptureStillImageOutput }.first
            // Эта настройка необходима, иначе AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(_:) будет крэшиться
            output?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        }
    }
    
    // MARK: - CameraService
    
    func setCaptureSessionRunning(_ needsRunning: Bool) {
        if needsRunning {
            cameraOutput?.startCapture()
        } else {
            cameraOutput?.stopCapture()
        }
    }
    
    func canToggleCamera(completion: @escaping (Bool) -> ()) {
        completion(frontCamera != nil && backCamera != nil)
    }
    
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ()) {
        cameraOutput?.rotateCamera()
        completion(outputOrientationForCamera(activeCamera))
    }
    
    var isFlashAvailable: Bool {
        return backCamera?.isFlashAvailable == true
    }
    
    var isFlashEnabled: Bool {
        return backCamera?.flashMode == .on
    }
    
    func setFlashEnabled(_ enabled: Bool) -> Bool {
        
        guard let camera = backCamera else { return false }
        
        do {
            let flashMode: AVCaptureFlashMode = enabled ? .on : .off
            
            try camera.lockForConfiguration()
            
            if camera.isFlashModeSupported(flashMode) {
                camera.flashMode = flashMode
            }
            
            camera.unlockForConfiguration()
            
            return true
            
        } catch {
            return false
        }
    }
    
    func takePhoto(completion: @escaping (PhotoFromCamera?) -> ()) {
        
        guard let output = output, let connection = videoOutputConnection() else {
            completion(nil)
            return
        }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = avOrientationForCurrentDeviceOrientation()
        }
        
        output.captureStillImageAsynchronously(from: connection) { [weak self] sampleBuffer, error in
            self?.savePhoto(sampleBuffer: sampleBuffer) { photo in
                DispatchQueue.main.async {
                    completion(photo)
                }
            }
        }
    }
    
    private func avOrientationForCurrentDeviceOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:        // да-да
            return .landscapeRight  // все именно так
        case .landscapeRight:       // иначе получаются перевертыши
            return .landscapeLeft   // rotation is hard on iOS (c)
        default:
            return .portrait
        }
    }
    
    // MARK: - Private
    
    private func savePhoto(sampleBuffer: CMSampleBuffer?, completion: @escaping (PhotoFromCamera?) -> ()) {
        
        let path = randomTemporaryPhotoFilePath()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = sampleBuffer.flatMap({ AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation($0) }) {
                do {
                    try data.write(to: URL(fileURLWithPath: path), options: [.atomicWrite])
                    completion(PhotoFromCamera(path: path))
                } catch {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func videoOutputConnection() -> AVCaptureConnection? {
        
        guard let output = output else { return nil }
        
        for connection in output.connections {
            
            if let connection = connection as? AVCaptureConnection,
               let inputPorts = connection.inputPorts as? [AVCaptureInputPort] {
                
                let connectionContainsVideoPort = inputPorts.filter({ $0.mediaType == AVMediaTypeVideo }).count > 0
                
                if connectionContainsVideoPort {
                    return connection
                }
            }
        }
        
        return nil
    }
    
    private static func configureCamera(_ camera: AVCaptureDevice?) throws {
        try camera?.lockForConfiguration()
        camera?.isSubjectAreaChangeMonitoringEnabled = true
        camera?.unlockForConfiguration()
    }
    
    private func randomTemporaryPhotoFilePath() -> String {
        let tempDirPath = NSTemporaryDirectory() as NSString
        let tempName = "\(NSUUID().uuidString).jpg"
        return tempDirPath.appendingPathComponent(tempName)
    }
    
    private func outputOrientationForCamera(_ camera: AVCaptureDevice?) -> ExifOrientation {
        if camera == frontCamera {
            return .leftMirrored
        } else {
            return .left
        }
    }
}
