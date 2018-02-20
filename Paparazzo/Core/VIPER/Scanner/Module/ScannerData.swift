import UIKit

public struct ScannerData {
    public let hapticFeedbackEnabled: Bool
    public let initialActiveCameraType: CameraType
    
    public init(
        hapticFeedbackEnabled: Bool = false,
        initialActiveCameraType: CameraType = .back)
    {
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.initialActiveCameraType = initialActiveCameraType
    }
}
