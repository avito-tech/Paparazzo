import UIKit

protocol DeviceOrientationService: class {
    var currentOrientation: DeviceOrientation { get }
    var onOrientationChange: (DeviceOrientation -> ())? { get set }
}

enum DeviceOrientation {
    
    case Unknown
    case Portrait // Device oriented vertically, home button on the bottom
    case PortraitUpsideDown // Device oriented vertically, home button on the top
    case LandscapeLeft // Device oriented horizontally, home button on the right
    case LandscapeRight // Device oriented horizontally, home button on the left
    
    private init(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .Portrait:
            self = .Portrait
        case .PortraitUpsideDown:
            self = .PortraitUpsideDown
        case .LandscapeLeft:
            self = .LandscapeLeft
        case .LandscapeRight:
            self = .LandscapeRight
        default:
            self = .Unknown
        }
    }
}

final class DeviceOrientationServiceImpl: DeviceOrientationService {
    
    var currentOrientation: DeviceOrientation {
        return DeviceOrientation(device.orientation)
    }
    
    var onOrientationChange: (DeviceOrientation -> ())?
    
    private let device = UIDevice.currentDevice()
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(DeviceOrientationServiceImpl.onOrientationChange(_:)),
            name: UIDeviceOrientationDidChangeNotification,
            object: device
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func onOrientationChange(notification: NSNotification) {
        
        let newOrientation = device.orientation
        
        // Если новая ориентация .FaceUp или .FaceDown, то считаем, что ничего не изменилось
        if newOrientation != .FaceUp && newOrientation != .FaceDown {
            onOrientationChange?(DeviceOrientation(newOrientation))
        }
    }
}
