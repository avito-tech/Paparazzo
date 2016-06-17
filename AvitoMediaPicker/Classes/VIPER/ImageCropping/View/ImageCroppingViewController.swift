import UIKit

final class ImageCroppingViewController: BaseViewControllerSwift, ImageCroppingViewInput {
    
    private let imageCroppingView = ImageCroppingView()
    
    // MARK: - CroppingViewInput
    override init() {
        super.init()
        title = "Crop"
    }
    
    override func loadView() {
        view = imageCroppingView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)    // временно, просто чтобы не застревать на кропе
    }
}
