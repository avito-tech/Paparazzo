import UIKit

final class ImageCroppingViewController: UIViewController, ImageCroppingViewInput {
    
    private let imageCroppingView = ImageCroppingView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = imageCroppingView
    }
    
    // MARK: - ImageCroppingViewInput
    
    var onDiscardButtonTap: (() -> ())? {
        get { return imageCroppingView.onDiscardButtonTap }
        set { imageCroppingView.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: (() -> ())? {
        get { return imageCroppingView.onConfirmButtonTap }
        set { imageCroppingView.onConfirmButtonTap = newValue }
    }
    
    func setImage(image: ImageSource) {
        imageCroppingView.setImage(image)
    }
    
    // MARK: - ImageCroppingViewController
    
    func setTheme(theme: ImageCroppingUITheme) {
        imageCroppingView.setTheme(theme)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}
