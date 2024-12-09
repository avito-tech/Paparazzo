import UIKit
import AVFoundation

protocol DeviceOrientationService: AnyObject {
    var currentOrientation: DeviceOrientation { get }
    var onOrientationChange: ((DeviceOrientation) -> ())? { get set }
}

enum DeviceOrientation {
    
    case unknown
    case portrait // Device oriented vertically, home button on the bottom
    case portraitUpsideDown // Device oriented vertically, home button on the top
    case landscapeLeft // Device oriented horizontally, home button on the right
    case landscapeRight // Device oriented horizontally, home button on the left
    
    fileprivate init(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            self = .unknown
        }
    }
}

final class DeviceOrientationServiceImpl: DeviceOrientationService {
    
    var currentOrientation: DeviceOrientation {
        return DeviceOrientation(device.orientation)
    }
    
    var onOrientationChange: ((DeviceOrientation) -> ())?
    
    private let device = UIDevice.current
    
    init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onOrientationChange(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: device
        )
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func onOrientationChange(_ notification: NSNotification) {
        
        let newOrientation = device.orientation
        
        // Если новая ориентация .FaceUp или .FaceDown, то считаем, что ничего не изменилось
        if newOrientation != .faceUp && newOrientation != .faceDown {
            onOrientationChange?(DeviceOrientation(newOrientation))
        }
    }
}

extension DeviceOrientation {
    func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .portrait:
            return .right
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        case .portraitUpsideDown:
            return .left
        case .unknown:
            return .left
        }
    }
}

extension DeviceOrientation {
    var toAVCaptureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        case .unknown:
            return .portrait
        }
    }
}
