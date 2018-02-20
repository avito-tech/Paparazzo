import UIKit

public struct ScannerData {
    public let initialActiveCameraType: CameraType
    
    public init(initialActiveCameraType: CameraType = .back) {
        self.initialActiveCameraType = initialActiveCameraType
    }
}
