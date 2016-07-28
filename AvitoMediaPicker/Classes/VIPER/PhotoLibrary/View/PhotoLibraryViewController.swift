import UIKit

final class PhotoLibraryViewController: UIViewController, PhotoLibraryViewInput {
    
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
        
        onViewDidLoad?()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - PhotoLibraryViewInput
    
    var onItemSelect: (PhotoLibraryItem -> ())?
    var onPickButtonTap: (() -> ())?
    var onViewDidLoad: (() -> ())?
    
    func setCellsData(items: [PhotoLibraryItemCellData]) {
        photoLibraryView.setCellsData(items)
    }
    
    func setCanSelectMoreItems(canSelectMoreItems: Bool) {
        photoLibraryView.canSelectMoreItems = canSelectMoreItems
    }
    
    func setDimsUnselectedItems(dimUnselectedItems: Bool) {
        photoLibraryView.dimsUnselectedItems = dimUnselectedItems
    }
    
    func setPickButtonEnabled(enabled: Bool) {
        navigationItem.rightBarButtonItem?.enabled = enabled
    }
    
    func scrollToBottom() {
        photoLibraryView.scrollToBottom()
    }
    
    func setTheme(theme: PhotoLibraryUITheme) {
        photoLibraryView.setTheme(theme)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
    
    // MARK: - Private
    
    @objc private func onPickButtonTap(sender: UIBarButtonItem) {
        onPickButtonTap?()
    }
}
