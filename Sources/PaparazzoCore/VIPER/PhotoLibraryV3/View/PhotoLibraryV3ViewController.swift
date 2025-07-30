import AVFoundation
import ImageSource
import UIKit

final class PhotoLibraryV3ViewController: PaparazzoViewController, PhotoLibraryV3ViewInput, ThemeConfigurable {
    typealias ThemeType = PhotoLibraryV3UITheme & NewCameraUITheme
    
    // MARK: Properties
    
    private let photoLibraryView: PhotoLibraryV3View
    private let deviceOrientationService: DeviceOrientationService
    private var theme: PhotoLibraryV3UITheme?
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return photoLibraryView.previewLayer
    }
    
    // MARK: Handler
    
    var onItemSelect: ((PhotoLibraryV3Item) -> ())?
    var onViewDidLoad: (() -> ())?
    var onViewWillAppear: (() -> ())?
    var onViewDidAppear: (() -> ())?
    var onViewDidDisappear: ((Bool) -> ())?
    
    var onTitleTap: (() -> ())? {
        get { return photoLibraryView.onTitleTap }
        set { photoLibraryView.onTitleTap = newValue }
    }
    
    var onContinueButtonTap: (() -> ())? {
        get { return photoLibraryView.onContinueButtonTap }
        set { photoLibraryView.onContinueButtonTap = newValue }
    }
    
    var onCloseButtonTap: (() -> ())? {
        get { return photoLibraryView.onCloseButtonTap }
        set { photoLibraryView.onCloseButtonTap = newValue }
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return photoLibraryView.onAccessDeniedButtonTap }
        set { photoLibraryView.onAccessDeniedButtonTap = newValue }
    }
    
    var onDimViewTap: (() -> ())? {
        get { return photoLibraryView.onDimViewTap }
        set { photoLibraryView.onDimViewTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { return photoLibraryView.onLastPhotoThumbnailTap }
        set { photoLibraryView.onLastPhotoThumbnailTap = newValue }
    }
    
    // MARK: Init
    
    init(deviceOrientationService: DeviceOrientationService) {
        photoLibraryView = PhotoLibraryV3View()
        self.deviceOrientationService = deviceOrientationService
        super.init()
        
        transitioningDelegate = PhotoLibraryToCameraTransitioningDelegate.shared
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PhotoLibraryV3ViewController
    func previewFrame(forBounds bounds: CGRect) -> CGRect {
        return photoLibraryView.previewFrame(forBounds: bounds)
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        photoLibraryView.setPreviewLayer(previewLayer)
    }
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = photoLibraryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if !UIDevice.current.hasTopSafeAreaInset {
            UIApplication.shared.setStatusBarHidden(true, with: animated ? .fade : .none)
        }
        
        onViewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onViewDidAppear?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        onViewDidDisappear?(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer?.connection?.videoOrientation = deviceOrientationService.currentOrientation.toAVCaptureVideoOrientation
    }
    
    // MARK: Override
    
    override var prefersStatusBarHidden: Bool {
        return !UIDevice.current.hasTopSafeAreaInset
    }
    
    override public var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return super.preferredInterfaceOrientationForPresentation
        } else {
            return .portrait
        }
    }
    
    // MARK: Public methods
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        photoLibraryView.setTheme(theme)
    }
    
    @nonobjc func setTitle(_ title: String) {
        photoLibraryView.setTitle(title)
    }
    
    func setTitleVisible(_ visible: Bool) {
        photoLibraryView.setTitleVisible(visible)
    }
    
    func setContinueButtonTitle(_ title: String) {
        photoLibraryView.setContinueButtonTitle(title)
    }
    
    func setContinueButtonVisible(_ isVisible: Bool) {
        photoLibraryView.setContinueButtonVisible(isVisible)
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        photoLibraryView.setContinueButtonStyle(style)
    }
    
    func setContinueButtonPlacement(_ placement: MediaPickerContinueButtonPlacement) {
        photoLibraryView.setContinueButtonPlacement(placement)
    }
    
    func setPlaceholderState(_ state: PhotoLibraryPlaceholderState) {
        switch state {
        case .hidden:
            photoLibraryView.setPlaceholderVisible(false)
        case .visible(let title):
            photoLibraryView.setPlaceholderTitle(title)
            photoLibraryView.setPlaceholderVisible(true)
        }
    }
    
    func setCameraViewData(_ viewData: PhotoLibraryV3CameraViewData?) {
        photoLibraryView.setCameraViewData(viewData)
    }
    
    func setItems(_ items: [PhotoLibraryV3ItemCellData], scrollToTop: Bool, completion: (() -> ())?) {
        photoLibraryView.setItems(items, scrollToTop: scrollToTop, completion: completion)
    }
    
    func applyChanges(_ changes: PhotoLibraryV3ViewChanges, completion: @escaping () -> ()) {
        photoLibraryView.applyChanges(changes, completion: completion)
    }
    
    func setCanSelectMoreItems(_ canSelectMoreItems: Bool) {
        photoLibraryView.canSelectMoreItems = canSelectMoreItems
    }
    
    func setDimsUnselectedItems(_ dimUnselectedItems: Bool) {
        photoLibraryView.dimsUnselectedItems = dimUnselectedItems
    }
    
    func deselectItem(with imageSource: ImageSource) -> Bool {
        return photoLibraryView.deselectCell(with: imageSource)
    }
    
    func deselectAllItems() {
        photoLibraryView.deselectAndAdjustAllCells()
    }
    
    func reloadSelectedItems() {
        photoLibraryView.reloadSelectedItems()
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
    
    func setProgressVisible(_ visible: Bool) {
        photoLibraryView.setProgressVisible(visible)
    }
    
    func setHeaderVisible(_ visible: Bool) {
        photoLibraryView.setHeaderVisible(visible)
    }
    
    func setAlbums(_ albums: [PhotoLibraryAlbumCellData]) {
        photoLibraryView.setAlbums(albums)
    }
    
    func selectAlbum(withId id: String) {
        photoLibraryView.selectAlbum(withId: id)
    }
    
    func showAlbumsList() {
        photoLibraryView.showAlbumsList()
    }
    
    func hideAlbumsList() {
        photoLibraryView.hideAlbumsList()
    }
    
    func toggleAlbumsList() {
        photoLibraryView.toggleAlbumsList()
    }
    
    func setSelectedPhotosBarState(_ state: SelectedPhotosBarState) {
        photoLibraryView.setSelectedPhotosBarState(state)
    }
    
    func setDoneButtonTitle(_ title: String) {
        photoLibraryView.setDoneButtonTitle(title)
    }
    
    func setPlaceholderText(_ text: String) {
        photoLibraryView.setPlaceholderText(text)
    }
}

// MARK: - Private methods

private extension PhotoLibraryV3ViewController {
    @objc func onCloseButtonTap(_ sender: UIBarButtonItem) {
        onCloseButtonTap?()
    }
    
    @objc func onContinueButtonTap(_ sender: UIBarButtonItem) {
        onContinueButtonTap?()
    }
}
