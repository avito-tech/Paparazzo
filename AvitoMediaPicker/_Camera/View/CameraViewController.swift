import UIKit
import AVFoundation

final class CameraViewController: UIViewController, CameraViewInput {
    
    let interactor = CameraInteractorImpl() // TODO: inject
    private var cameraView: CameraView?
    
    override func loadView() {
        cameraView = CameraView(captureSession: interactor.captureSession)
        view = cameraView
    }
}
