import ImageSource
import UIKit

protocol ScannerViewInput: AnyObject {
    
    func adjustForDeviceOrientation(_: DeviceOrientation)
    
    var onCloseButtonTap: (() -> ())? { get set }
    
    func showInfoMessage(_ message: String, timeout: TimeInterval)
    
    var onViewDidLoad: (() -> ())? { get set }
    var onViewDidAppear: ((_ animated: Bool) -> ())? { get set }
    var onViewWillAppear: ((_ animated: Bool) -> ())? { get set }
    var onViewDidDisappear: ((_ animated: Bool) -> ())? { get set }
}
