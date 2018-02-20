import UIKit

public struct ScannerData {
    public let initialActiveCameraType: CameraType
    public let cameraCaptureOutputHandlers: [CameraCaptureOutputHandler]
    
    public init(
        initialActiveCameraType: CameraType = .back,
        cameraCaptureOutputHandlers: [CameraCaptureOutputHandler] = [])
    {
        self.initialActiveCameraType = initialActiveCameraType
        self.cameraCaptureOutputHandlers = cameraCaptureOutputHandlers
    }
}
