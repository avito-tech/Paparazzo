import UIKit

final class PhotoLibraryViewController: UIViewController, PhotoLibraryViewInput {
    
    private let photoLibraryView = PhotoLibraryView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = photoLibraryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - PhotoLibraryViewInput
    
    var onItemSelect: (PhotoLibraryItem -> ())?
    var onPickButtonTap: (() -> ())?
    var onCancelButtonTap: (() -> ())?
    var onViewDidLoad: (() -> ())?
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return photoLibraryView.onAccessDeniedButtonTap }
        set { photoLibraryView.onAccessDeniedButtonTap = newValue }
    }
    
    @nonobjc func setTitle(title: String) {
        self.title = title
    }
    
    func setCancelButtonTitle(title: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: title,
            style: .Plain,
            target: self,
            action: #selector(PhotoLibraryViewController.onCancelButtonTap(_:))
        )
    }
    
    func setDoneButtonTitle(title: String) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: title,
            style: .Done,
            target: self,
            action: #selector(PhotoLibraryViewController.onPickButtonTap(_:))
        )
    }
    
    func applyChanges(changes: PhotoLibraryViewChanges, animated: Bool, completion: (() -> ())?) {
        photoLibraryView.applyChanges(changes, animated: animated, completion: completion)
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
    
    func setAccessDeniedViewVisible(visible: Bool) {
        photoLibraryView.setAccessDeniedViewVisible(visible)
    }
    
    func setAccessDeniedTitle(title: String) {
        photoLibraryView.setAccessDeniedTitle(title)
    }
    
    func setAccessDeniedMessage(message: String) {
        photoLibraryView.setAccessDeniedMessage(message)
    }
    
    func setAccessDeniedButtonTitle(title: String) {
        photoLibraryView.setAccessDeniedButtonTitle(title)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
    
    // MARK: - Private
    
    @objc private func onCancelButtonTap(sender: UIBarButtonItem) {
        onCancelButtonTap?()
    }
    
    @objc private func onPickButtonTap(sender: UIBarButtonItem) {
        onPickButtonTap?()
    }
}
