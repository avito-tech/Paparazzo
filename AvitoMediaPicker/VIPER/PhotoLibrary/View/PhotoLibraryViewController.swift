import UIKit

final class PhotoLibraryViewController: BaseViewControllerSwift, PhotoLibraryViewInput {
    
    private let photoLibraryView = PhotoLibraryView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = photoLibraryView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - PhotoLibraryViewInput
    
    func setItems(items: [PhotoLibraryItem]) {
        photoLibraryView.setItems(items)
    }
}
