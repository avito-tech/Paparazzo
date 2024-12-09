import UIKit

public struct ScannerData {
    public let initialActiveCameraType: CameraType
    public let cameraCaptureOutputHandlers: [ScannerOutputHandler]
    
    public init(
        initialActiveCameraType: CameraType = .back,
        cameraCaptureOutputHandlers: [ScannerOutputHandler] = [])
    {
        self.initialActiveCameraType = initialActiveCameraType
        self.cameraCaptureOutputHandlers = cameraCaptureOutputHandlers
    }
}

@objc public protocol ScannerOutputHandler: CameraCaptureOutputHandler {
    var orientation: UInt32 { get set }
}
