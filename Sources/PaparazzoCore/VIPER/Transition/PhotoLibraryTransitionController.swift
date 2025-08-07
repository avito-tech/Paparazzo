import UIKit
import AVFoundation

protocol PhotoLibraryTransitionController where Self: UIViewController {
    var previewLayer: AVCaptureVideoPreviewLayer? { get }
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?)
}
