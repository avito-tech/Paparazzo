import AVFoundation

protocol CameraViewInput: class {
    func setOutputParameters(_: CameraOutputParameters)
    func setOutputOrientation(_: ExifOrientation)
}
