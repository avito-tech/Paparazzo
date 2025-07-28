import ImageSource

extension ExifOrientation {
    func byApplyingDeviceOrientation(_ orientation: DeviceOrientation) -> ExifOrientation {
        switch orientation {
        case .portrait:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        case .portraitUpsideDown:
            return .right
        case .unknown:
            return .left
        }
    }
}
