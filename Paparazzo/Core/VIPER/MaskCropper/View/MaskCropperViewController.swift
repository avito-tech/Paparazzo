import ImageSource

final class MaskCropperViewController:
    PaparazzoViewController,
    MaskCropperViewInput,
    ThemeConfigurable
{
    
    typealias ThemeType = MaskCropperUITheme
    
    private let circleImageCroppingView: MaskCropperView
    
    // MARK: - Init
    
    init(croppingOverlayProvider: CroppingOverlayProvider) {
        circleImageCroppingView = MaskCropperView(
            croppingOverlayProvider: croppingOverlayProvider)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = circleImageCroppingView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Cropping doesn't work in landscape at the moment.
        // Forcing orientation doesn't produce severe issues at the moment.
        forcePortraitOrientation()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - MaskCropperViewInput
    
    var onConfirmTap: ((CGImage?) -> ())? {
        get { return circleImageCroppingView.onConfirmTap }
        set { circleImageCroppingView.onConfirmTap = newValue }
    }
    
    var onCloseTap: (() -> ())? {
        get { return circleImageCroppingView.onCloseTap }
        set { circleImageCroppingView.onCloseTap = newValue }
    }
    
    var onDiscardTap: (() -> ())? {
        get { return circleImageCroppingView.onDiscardTap }
        set { circleImageCroppingView.onDiscardTap = newValue }
    }
    
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())?
    
    func setConfirmButtonTitle(_ title: String) {
        circleImageCroppingView.setConfirmButtonTitle(title)
    }
    
    func setImage(_ imageSource: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ()) {
        circleImageCroppingView.setImage(imageSource, previewImage: previewImage, completion: completion)
    }
    
    func setCanvasSize(_ canvasSize: CGSize) {
        circleImageCroppingView.setCanvasSize(canvasSize)
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        circleImageCroppingView.setCroppingParameters(parameters)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        circleImageCroppingView.setControlsEnabled(enabled)
    }
    
    func setCroppingOverlayProvider(_: CroppingOverlayProvider) {
        
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        circleImageCroppingView.setTheme(theme)
    }
    
    // MARK: - Private
    
    private func forcePortraitOrientation() {
        let initialDeviceOrientation = UIDevice.current.orientation
        let targetDeviceOrientation = UIDeviceOrientation.portrait
        let targetInterfaceOrientation = UIInterfaceOrientation.portrait
        
        if UIDevice.current.orientation != targetDeviceOrientation {
            
            UIApplication.shared.setStatusBarOrientation(targetInterfaceOrientation, animated: true)
            UIDevice.current.setValue(NSNumber(value: targetInterfaceOrientation.rawValue as Int), forKey: "orientation")
            
            DispatchQueue.main.async {
                UIDevice.current.setValue(NSNumber(value: initialDeviceOrientation.rawValue as Int), forKey: "orientation")
            }
        }
    }
    
}
