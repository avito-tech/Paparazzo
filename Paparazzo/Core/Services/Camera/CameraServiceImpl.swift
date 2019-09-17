import AVFoundation
import ImageIO
import ImageSource
import Photos

public enum CameraType {
    case back
    case front
}

final class CameraServiceImpl: CameraService {
    
    // MARK: - Private types and properties
    
    private struct Error: Swift.Error {}
    
    private var imageStorage: ImageStorage
    private var captureSession: AVCaptureSession?
    private var output: AVCaptureStillImageOutput?
    private var backCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private var activeCamera: AVCaptureDevice? {
        return camera(for: activeCameraType)
    }
    
    private var activeCameraType: CameraType

    var isMetalEnabled: Bool = false

    // MARK: - Init
    
    init(
        initialActiveCameraType: CameraType,
        imageStorage: ImageStorage)
    {

        self.imageStorage = imageStorage

        let videoDevices = AVCaptureDevice.devices(for: .video)
        
        backCamera = videoDevices.filter({ $0.position == .back }).first
        frontCamera = videoDevices.filter({ $0.position == .front }).first
        
        self.activeCameraType = initialActiveCameraType
    }
    
    func getCaptureSession(completion: @escaping (AVCaptureSession?) -> ()) {
        
        func callCompletionOnMainQueue(with session: AVCaptureSession?) {
            DispatchQueue.main.async {
                completion(session)
            }
        }
        
        captureSessionSetupQueue.async { [weak self] in
            
            if let captureSession = self?.captureSession {
                callCompletionOnMainQueue(with: captureSession)
                
            } else {
                
                let mediaType = AVMediaType.video
                
                switch AVCaptureDevice.authorizationStatus(for: mediaType) {
                    
                case .authorized:
                    self?.setUpCaptureSession()
                    callCompletionOnMainQueue(with: self?.captureSession)
                    
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: mediaType) { granted in
                        self?.captureSessionSetupQueue.async {
                            if let captureSession = self?.captureSession {
                                callCompletionOnMainQueue(with: captureSession)
                            } else if granted {
                                self?.setUpCaptureSession()
                                callCompletionOnMainQueue(with: self?.captureSession)
                            } else {
                                callCompletionOnMainQueue(with: nil)
                            }
                        }
                    }
                    
                case .restricted, .denied:
                    callCompletionOnMainQueue(with: nil)
                }
            }
        }
    }
    
    func getOutputOrientation(completion: @escaping (ExifOrientation) -> ()) {
        completion(outputOrientationForCamera(activeCamera))
    }
    
    private func setUpCaptureSession() {
        
        do {
            #if arch(i386) || arch(x86_64)
                // Preventing crash in simulator
                throw Error()
            #endif
            
            guard let activeCamera = activeCamera else {
                throw Error()
            }
            
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            
            try CameraServiceImpl.configureCamera(backCamera)
            
            let input = try AVCaptureDeviceInput(device: activeCamera)
            
            let output = AVCaptureStillImageOutput()
            output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(output) {
                captureSession.addInput(input)
                captureSession.addOutput(output)
            } else {
                throw Error()
            }
            
            captureSession.startRunning()
            
            self.output = output
            self.captureSession = captureSession
            
            subscribeForNotifications(session: captureSession)
            
        } catch {
            self.output = nil
            self.captureSession = nil
        }
    }
    
    private func subscribeForNotifications(session: AVCaptureSession) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: session
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: session
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: .AVCaptureSessionRuntimeError,
            object: session
        )
    }
    
    private var shouldRestartSessionAfterInterruptionEnds = false
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        shouldRestartSessionAfterInterruptionEnds = (captureSession?.isRunning == true)
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        if shouldRestartSessionAfterInterruptionEnds && captureSession?.isRunning == false {
            captureSessionSetupQueue.async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print(error)
    }
    
    // MARK: - CameraService
    
    func setCaptureSessionRunning(_ needsRunning: Bool) {
        captureSessionSetupQueue.async {
            if needsRunning {
                self.captureSession?.startRunning()
            } else {
                self.captureSession?.stopRunning()
            }
        }
    }
    
    func focusOnPoint(_ focusPoint: CGPoint) -> Bool {
        guard let activeCamera = self.activeCamera,
            activeCamera.isFocusPointOfInterestSupported || activeCamera.isExposurePointOfInterestSupported else {
            return false
        }
        
        do {
            try activeCamera.lockForConfiguration()
            
            if activeCamera.isFocusPointOfInterestSupported {
                activeCamera.focusPointOfInterest = focusPoint
                activeCamera.focusMode = .continuousAutoFocus
            }
            
            if activeCamera.isExposurePointOfInterestSupported {
                activeCamera.exposurePointOfInterest = focusPoint
                activeCamera.exposureMode = .continuousAutoExposure
            }
            
            activeCamera.unlockForConfiguration()
            
            return true
        }
        catch {
            debugPrint("Couldn't focus camera: \(error)")
            return false
        }
    }
    
    func canToggleCamera(completion: @escaping (Bool) -> ()) {
        completion(frontCamera != nil && backCamera != nil)
    }
    
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ()) {
        guard let captureSession = captureSession else { return }
        
        do {
            
            let targetCameraType: CameraType = (activeCamera == backCamera) ? .front : .back
            
            guard let targetCamera = camera(for: targetCameraType) else {
                throw Error()
            }
            
            let newInput = try AVCaptureDeviceInput(device: targetCamera)
            
            try captureSession.configure {
                
                let currentInputs = captureSession.inputs as? [AVCaptureInput]
                currentInputs?.forEach { captureSession.removeInput($0) }
                
                // Always reset preset before testing canAddInput because preset will cause it to return NO
                captureSession.sessionPreset = .high
                
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                }
                
                captureSession.sessionPreset = .photo
                
                setupOrientationFor(captureSession: captureSession, cameraType: targetCameraType)
                
                try CameraServiceImpl.configureCamera(targetCamera)
            }
            
            activeCameraType = targetCameraType
            
        } catch {
            debugPrint("Couldn't toggle camera: \(error)")
        }
        
        completion(outputOrientationForCamera(activeCamera))
    }
    
    var isFlashAvailable: Bool {
        return backCamera?.isFlashAvailable == true
    }
    
    var isFlashEnabled: Bool {
        return backCamera?.flashMode == .on
    }
    
    private func setupOrientationFor(captureSession: AVCaptureSession?, cameraType: CameraType) {
        guard let captureSession = captureSession else { return }
        
        for captureOutput in captureSession.outputs {
            for connection in captureOutput.connections {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                    connection.isVideoMirrored = cameraType == .front
                }
            }
        }
    }
    
    func setFlashEnabled(_ enabled: Bool) -> Bool {
        
        guard let camera = backCamera else { return false }
        
        do {
            let flashMode: AVCaptureDevice.FlashMode = enabled ? .on : .off
            
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
            return completion(nil)
        }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = avOrientationForCurrentDeviceOrientation()
        }
        
        output.captureStillImageAsynchronously(from: connection) { [weak self] sampleBuffer, error in
            self?.imageStorage.save(sampleBuffer: sampleBuffer, callbackQueue: .main) { path in
                guard let path = path else {
                    completion(nil)
                    return
                }
                completion(PhotoFromCamera(path: path))
            }
        }
    }
    
    func takePhotoToPhotoLibrary(completion callersCompletion: @escaping (PhotoLibraryItem?) -> ()) {
        
        func completion(_ mediaPickerItem: PhotoLibraryItem?) {
            dispatch_to_main_queue {
                callersCompletion(mediaPickerItem)
            }
        }
        
        guard let output = output, let connection = videoOutputConnection() else {
            return completion(nil)
        }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = avOrientationForCurrentDeviceOrientation()
        }
        
        output.captureStillImageAsynchronously(from: connection) { [weak self] sampleBuffer, error in
            DispatchQueue.global(qos: .userInitiated).async {
                
                guard let imageData =
                    sampleBuffer.flatMap({ AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation($0) })
                    else {
                        return completion(nil)
                    }
                
                PHPhotoLibrary.requestAuthorization { status in
                    guard status == .authorized else {
                        return completion(nil)
                    }
                    
                    var placeholderForCreatedAsset: PHObjectPlaceholder?
                    
                    PHPhotoLibrary.shared().performChanges({
                        // Add the captured photo's file data as the main resource for the Photos asset.
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .photo, data: imageData, options: nil)
                        
                        placeholderForCreatedAsset = creationRequest.placeholderForCreatedAsset
                        
                    }, completionHandler: { isSuccessful, error in
                        guard isSuccessful, let localIdentifier = placeholderForCreatedAsset?.localIdentifier else {
                            return completion(nil)
                        }
                        
                        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                        
                        completion(fetchResult.lastObject.flatMap { asset in
                            PhotoLibraryItem(image: PHAssetImageSource(asset: asset))
                        })
                    })
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
    
    private let captureSessionSetupQueue = DispatchQueue(label: "ru.avito.AvitoMediaPicker.CameraServiceImpl.captureSessionSetupQueue")
    
    private func videoOutputConnection() -> AVCaptureConnection? {
        
        guard let output = output else { return nil }
        
        for connection in output.connections {
            
            let inputPorts = connection.inputPorts
            let connectionContainsVideoPort = inputPorts.filter { $0.mediaType == .video }.count > 0
            
            if connectionContainsVideoPort {
                return connection
            }
        }
        
        return nil
    }
    
    private static func configureCamera(_ camera: AVCaptureDevice?) throws {
        try camera?.lockForConfiguration()
        camera?.isSubjectAreaChangeMonitoringEnabled = true
        camera?.unlockForConfiguration()
    }
    
    private func outputOrientationForCamera(_ camera: AVCaptureDevice?) -> ExifOrientation {
        if camera == frontCamera {
            return .leftMirrored
        } else {
            return .left
        }
    }
    
    private func camera(for cameraType: CameraType) -> AVCaptureDevice? {
        switch cameraType {
        case .back:
            return backCamera
        case .front:
            return frontCamera
        }
    }
    
}
