import ImageSource
import UIKit

final class MediaPickerViewController: UIViewController, MediaPickerViewInput {
    
    private var isBeingRotated: Bool = false
    private let mediaPickerView = MediaPickerView()
    private var layoutSubviewsPromise = Promise<Void>()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        view.addSubview(mediaPickerView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        onViewDidLoad?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        layoutMediaPickerView(interfaceOrientation: interfaceOrientation)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // See viewDidAppear
        // UIDevice.current.userInterfaceIdiom restricts the klusge to iPad. It is only an iPad issue.
        if UIDevice.current.userInterfaceIdiom == .pad {
            mediaPickerView.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. Open this view controller
        // 2. Push another view controller
        // 3. Rotate device
        // 4. Pop to this view controller
        //
        // Without the following lines views go wild, it looks like they are chaotically placed.
        //
        // I've spent about 4-5 hours fixing it.
        //
        // Note that there is no check for iPad here. If alpha is 0 we must animate fade in in any case
        //
        if mediaPickerView.alpha == 0 {
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.mediaPickerView.alpha = 1
                })
            }
        }
        
        // AI-3326: костыль для iOS 8, на котором после дисмисса модального окна или возврата с предыдущего экрана
        // OpenGL рандомно (не каждый раз) прекращает отрисовку
        mediaPickerView.reloadCamera()
        
        onViewDidAppear?(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isBeingRotated {
            layoutMediaPickerView(interfaceOrientation: interfaceOrientation)
        }
        onPreviewSizeDetermined?(mediaPickerView.previewSize)
        layoutSubviewsPromise.fulfill()
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if shouldAutorotate {
            // Compensation animation for rotation.
            UIView.animate(
                withDuration: duration,
                animations: {
                    self.layoutMediaPickerView(interfaceOrientation: toInterfaceOrientation)
            })
        }
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotate(from: fromInterfaceOrientation)
        isBeingRotated = false
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willRotate(to: toInterfaceOrientation, duration: duration)
        isBeingRotated = true
    }
    
    override open var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return super.preferredInterfaceOrientationForPresentation
        } else {
            return .portrait
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - MediaPickerViewInput
    
    var onShutterButtonTap: (() -> ())? {
        get { return mediaPickerView.onShutterButtonTap }
        set { mediaPickerView.onShutterButtonTap = newValue }
    }

    var onPhotoLibraryButtonTap: (() -> ())? {
        get { return mediaPickerView.onPhotoLibraryButtonTap }
        set { mediaPickerView.onPhotoLibraryButtonTap = newValue }
    }

    var onFlashToggle: ((Bool) -> ())? {
        get { return mediaPickerView.onFlashToggle }
        set { mediaPickerView.onFlashToggle = newValue }
    }
    
    var onItemSelect: ((MediaPickerItem) -> ())? {
        get { return mediaPickerView.onItemSelect }
        set { mediaPickerView.onItemSelect = newValue }
    }
    
    var onItemMove: ((Int, Int) -> ())? {
        get { return mediaPickerView.onItemMove }
        set { mediaPickerView.onItemMove = newValue }
    }
    
    var onRemoveButtonTap: (() -> ())? {
        get { return mediaPickerView.onRemoveButtonTap }
        set { mediaPickerView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return mediaPickerView.onCropButtonTap }
        set { mediaPickerView.onCropButtonTap = newValue }
    }
    
    var onCameraThumbnailTap: (() -> ())? {
        get { return mediaPickerView.onCameraThumbnailTap }
        set { mediaPickerView.onCameraThumbnailTap = newValue }
    }
    
    var onSwipeToItem: ((MediaPickerItem) -> ())? {
        get { return mediaPickerView.onSwipeToItem }
        set { mediaPickerView.onSwipeToItem = newValue }
    }
    
    var onSwipeToCamera: (() -> ())? {
        get { return mediaPickerView.onSwipeToCamera }
        set { mediaPickerView.onSwipeToCamera = newValue }
    }
    
    var onSwipeToCameraProgressChange: ((CGFloat) -> ())? {
        get { return mediaPickerView.onSwipeToCameraProgressChange }
        set { mediaPickerView.onSwipeToCameraProgressChange = newValue }
    }
    
    var onViewDidLoad: (() -> ())?
    var onViewDidAppear: ((_ animated: Bool) -> ())?
    var onPreviewSizeDetermined: ((_ previewSize: CGSize) -> ())?
    
    func setMode(_ mode: MediaPickerViewMode) {
        // Этот метод может быть вызван до того, как вьюшка обретет frame, что критично для корректной работы
        // ее метода setMode. dispatch_async спасает ситуацию.
        DispatchQueue.main.async {
            self.mediaPickerView.setMode(mode)
        }
    }
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters) {
        mediaPickerView.setCameraOutputParameters(parameters)
    }
    
    func setCameraOutputOrientation(_ orientation: ExifOrientation) {
        mediaPickerView.setCameraOutputOrientation(orientation)
    }
    
    func setPhotoTitle(_ title: String) {
        mediaPickerView.setPhotoTitle(title)
    }
    
    func setPhotoTitleStyle(_ style: MediaPickerTitleStyle) {
        mediaPickerView.setPhotoTitleStyle(style)
    }
    
    func setPhotoTitleAlpha(_ alpha: CGFloat) {
        mediaPickerView.setPhotoTitleAlpha(alpha)
    }
    
    func setContinueButtonTitle(_ title: String) {
        mediaPickerView.setContinueButtonTitle(title)
    }
    
    func setContinueButtonEnabled(_ enabled: Bool) {
        mediaPickerView.setContinueButtonEnabled(enabled)
    }
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        UIView.animate(withDuration: 0.25) {
            self.mediaPickerView.adjustForDeviceOrientation(orientation)
        }
    }
    
    func setLatestLibraryPhoto(_ image: ImageSource?) {
        mediaPickerView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(_ visible: Bool) {
        mediaPickerView.setFlashButtonVisible(visible)
    }
    
    func setFlashButtonOn(_ isOn: Bool) {
        mediaPickerView.setFlashButtonOn(isOn)
    }
    
    func animateFlash() {
        mediaPickerView.animateFlash()
    }
    
    var onCloseButtonTap: (() -> ())? {
        get { return mediaPickerView.onCloseButtonTap }
        set { mediaPickerView.onCloseButtonTap = newValue }
    }
    
    var onContinueButtonTap: (() -> ())? {
        get { return mediaPickerView.onContinueButtonTap }
        set { mediaPickerView.onContinueButtonTap = newValue }
    }
    
    var onCameraToggleButtonTap: (() -> ())? {
        get { return mediaPickerView.onCameraToggleButtonTap }
        set { mediaPickerView.onCameraToggleButtonTap = newValue }
    }
    
    func setCameraToggleButtonVisible(_ visible: Bool) {
        mediaPickerView.setCameraToggleButtonVisible(visible)
    }

    func addItems(_ items: [MediaPickerItem], animated: Bool, completion: @escaping () -> ()) {
        mediaPickerView.addItems(items, animated: animated, completion: completion)
    }
    
    func updateItem(_ item: MediaPickerItem) {
        mediaPickerView.updateItem(item)
    }
    
    func removeItem(_ item: MediaPickerItem) {
        mediaPickerView.removeItem(item)
    }
    
    func selectItem(_ item: MediaPickerItem) {
        mediaPickerView.selectItem(item)
        onItemSelect?(item)
    }
    
    func scrollToItemThumbnail(_ item: MediaPickerItem, animated: Bool) {
        layoutSubviewsPromise.onFulfill { [weak self] _ in
            self?.mediaPickerView.scrollToItemThumbnail(item, animated: animated)
        }
    }
    
    func selectCamera() {
        mediaPickerView.selectCamera()
        onCameraThumbnailTap?()
    }
    
    func scrollToCameraThumbnail(animated: Bool) {
        layoutSubviewsPromise.onFulfill { [weak self] _ in
            self?.mediaPickerView.scrollToCameraThumbnail(animated: animated)
        }
    }
    
    func setCameraControlsEnabled(_ enabled: Bool) {
        mediaPickerView.setCameraControlsEnabled(enabled)
    }
    
    func setCameraButtonVisible(_ visible: Bool) {
        mediaPickerView.setCameraButtonVisible(visible)
    }
    
    func setShutterButtonEnabled(_ enabled: Bool) {
        mediaPickerView.setShutterButtonEnabled(enabled)
    }
    
    func setPhotoLibraryButtonEnabled(_ enabled: Bool) {
        mediaPickerView.setPhotoLibraryButtonEnabled(enabled)
    }
    
    // MARK: - MediaPickerViewController
    
    func setCameraView(_ view: UIView) {
        mediaPickerView.setCameraView(view)
    }
    
    func setTheme(_ theme: MediaPickerRootModuleUITheme) {
        mediaPickerView.setTheme(theme)
    }
    
    func setShowsCropButton(_ showsCropButton: Bool) {
        mediaPickerView.setShowsCropButton(showsCropButton)
    }
    
    // MARK: - Private
    
    func layoutMediaPickerView(interfaceOrientation: UIInterfaceOrientation) {
        // View is rotated, but mediaPickerView isn't.
        // It rotates in opposite direction and seems not rotated at all.
        // This allows to not force status bar orientation on this screen and keep UI same as
        // with forcing status bar orientation.
        mediaPickerView.transform = CGAffineTransform(interfaceOrientation: interfaceOrientation)
        mediaPickerView.frame = view.bounds
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(_ object: AnyObject) {
        disposables.append(object)
    }
}
