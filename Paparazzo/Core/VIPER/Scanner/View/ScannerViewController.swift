import ImageSource
import UIKit

final class ScannerViewController: PaparazzoViewController, ScannerViewInput, ThemeConfigurable {
    
    typealias ThemeType = ScannerRootModuleUITheme
    
    private let mediaPickerView = ScannerView()
    private var layoutSubviewsPromise = Promise<Void>()
    private var isAnimatingTransition: Bool = false
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .black
        view.addSubview(mediaPickerView)
        onViewDidLoad?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if !UIDevice.current.hasTopSafeAreaInset {
            UIApplication.shared.setStatusBarHidden(true, with: .fade)
        }
        
        onViewWillAppear?(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // See viewDidAppear
        // UIDevice.current.userInterfaceIdiom restricts the klusge to iPad. It is only an iPad issue.
        if UIDevice.current.userInterfaceIdiom == .pad {
            mediaPickerView.alpha = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDidDisappear?(animated)
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
        
        onViewDidAppear?(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isAnimatingTransition {
            layoutScannerView(bounds: view.bounds)
        }
        
        layoutSubviewsPromise.fulfill(())
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        isAnimatingTransition = true
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.layoutScannerView(bounds: context.containerView.bounds)
        },
        completion: { [weak self] _ in
            self?.isAnimatingTransition = false
        })
        
        super.viewWillTransition(to: size, with: coordinator)
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
        return !UIDevice.current.hasTopSafeAreaInset
    }
    
    // MARK: - ScannerViewInput
    
    var onViewDidLoad: (() -> ())?
    var onViewWillAppear: ((_ animated: Bool) -> ())?
    var onViewDidAppear: ((_ animated: Bool) -> ())?
    var onViewDidDisappear: ((_ animated: Bool) -> ())?
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        UIView.animate(withDuration: 0.25) {
            self.mediaPickerView.adjustForDeviceOrientation(orientation)
        }
    }
    
    var onCloseButtonTap: (() -> ())? {
        get { return mediaPickerView.onCloseButtonTap }
        set { mediaPickerView.onCloseButtonTap = newValue }
    }
    
    func showInfoMessage(_ message: String, timeout: TimeInterval) {
        mediaPickerView.showInfoMessage(message, timeout: timeout)
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        mediaPickerView.setTheme(theme)
    }
    
    // MARK: - ScannerViewController
    
    func setCameraView(_ view: UIView) {
        mediaPickerView.setCameraView(view)
    }
    
    // MARK: - Private
    
    func layoutScannerView(bounds: CGRect) {
        // View is rotated, but mediaPickerView isn't.
        // It rotates in opposite direction and seems not rotated at all.
        // This allows to not force status bar orientation on this screen and keep UI same as
        // with forcing status bar orientation.
        mediaPickerView.transform = CGAffineTransform(interfaceOrientation: interfaceOrientation)
        mediaPickerView.frame = bounds
    }
}
