import UIKit

final class PhotoLibraryViewController: BaseViewControllerSwift, PhotoLibraryViewInput {
    
    private let photoLibraryView = PhotoLibraryView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = photoLibraryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Выбрать",
            style: .Plain,
            target: self,
            action: #selector(PhotoLibraryViewController.onPickButtonTap(_:))
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - PhotoLibraryViewInput
    
    var onItemSelect: (PhotoLibraryItem -> ())?
    var onPickButtonTap: (() -> ())?
    
    func setCellsData(items: [PhotoLibraryItemCellData]) {
        photoLibraryView.setCellsData(items)
    }
    
    func setCanSelectMoreItems(canSelectMoreItems: Bool) {
        photoLibraryView.canSelectMoreItems = canSelectMoreItems
    }
    
    func setDimsUnselectedItems(dimUnselectedItems: Bool) {
        photoLibraryView.dimsUnselectedItems = dimUnselectedItems
    }
    
    func scrollToBottom() {
        photoLibraryView.scrollToBottom()
    }
    
    // MARK: - Private
    
    @objc private func onPickButtonTap(sender: UIBarButtonItem) {
        onPickButtonTap?()
    }
}
