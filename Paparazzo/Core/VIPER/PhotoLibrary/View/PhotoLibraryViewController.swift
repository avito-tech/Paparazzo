import UIKit

final class PhotoLibraryViewController: PaparazzoViewController, PhotoLibraryViewInput, ThemeConfigurable {
    
    typealias ThemeType = PhotoLibraryUITheme
    
    private let photoLibraryView = PhotoLibraryView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = photoLibraryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        hideNavigationBarShadow()
        
        UIApplication.shared.setStatusBarHidden(true, with: animated ? .fade : .none)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        photoLibraryView.setTheme(theme)
    }
    
    // MARK: - PhotoLibraryViewInput
    
    var onItemSelect: ((PhotoLibraryItem) -> ())?
    var onPickButtonTap: (() -> ())?
    var onCancelButtonTap: (() -> ())?
    var onViewDidLoad: (() -> ())?
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return photoLibraryView.onAccessDeniedButtonTap }
        set { photoLibraryView.onAccessDeniedButtonTap = newValue }
    }
    
    @nonobjc func setTitle(_ title: String) {
        self.title = title
    }
    
    func setCancelButtonTitle(_ title: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: #selector(onCancelButtonTap(_:))
        )
    }
    
    func setDoneButtonTitle(_ title: String) {
        pickBarButtonItem = UIBarButtonItem(
            title: title,
            style: .done,
            target: self,
            action: #selector(onPickButtonTap(_:))
        )
        
        if let font = theme?.photoLibraryDoneButtonFont {
            pickBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        }
    }
    
    func applyChanges(_ changes: PhotoLibraryViewChanges, animated: Bool, completion: (() -> ())?) {
        photoLibraryView.applyChanges(changes, animated: animated, completion: completion)
    }
    
    func setCanSelectMoreItems(_ canSelectMoreItems: Bool) {
        photoLibraryView.canSelectMoreItems = canSelectMoreItems
    }
    
    func setDimsUnselectedItems(_ dimUnselectedItems: Bool) {
        photoLibraryView.dimsUnselectedItems = dimUnselectedItems
    }
    
    func setPickButtonVisible(_ visible: Bool) {
        navigationItem.rightBarButtonItem = visible ? pickBarButtonItem : nil
    }
    
    func setPickButtonEnabled(_ enabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
    
    func scrollToBottom() {
        photoLibraryView.scrollToBottom()
    }
    
    func setAccessDeniedViewVisible(_ visible: Bool) {
        photoLibraryView.setAccessDeniedViewVisible(visible)
    }
    
    func setAccessDeniedTitle(_ title: String) {
        photoLibraryView.setAccessDeniedTitle(title)
    }
    
    func setAccessDeniedMessage(_ message: String) {
        photoLibraryView.setAccessDeniedMessage(message)
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        photoLibraryView.setAccessDeniedButtonTitle(title)
    }
    
    // MARK: - Private
    
    private var pickBarButtonItem: UIBarButtonItem?
    private var theme: PhotoLibraryUITheme?
    
    @objc private func onCancelButtonTap(_ sender: UIBarButtonItem) {
        onCancelButtonTap?()
    }
    
    @objc private func onPickButtonTap(_ sender: UIBarButtonItem) {
        onPickButtonTap?()
    }
    
    private func hideNavigationBarShadow() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
        navigationBar?.backgroundColor = .white
        navigationBar?.shadowImage = UIImage()
    }
}
