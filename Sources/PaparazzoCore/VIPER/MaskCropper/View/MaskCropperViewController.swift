import ImageSource
import UIKit

final class MaskCropperViewController:
    PaparazzoViewController,
    MaskCropperViewInput,
    ThemeConfigurable
{
    
    typealias ThemeType = MaskCropperUITheme
    
    private let maskCropperView: MaskCropperView
    
    // MARK: - Init
    
    init(croppingOverlayProvider: CroppingOverlayProvider) {
        maskCropperView = MaskCropperView(
            croppingOverlayProvider: croppingOverlayProvider)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = maskCropperView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Cropping doesn't work in landscape at the moment.
        // Forcing orientation doesn't produce severe issues at the moment.
        forcePortraitOrientation()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - MaskCropperViewInput
    
    var onConfirmTap: ((CGImage?) -> ())? {
        get { return maskCropperView.onConfirmTap }
        set { maskCropperView.onConfirmTap = newValue }
    }
    
    var onDiscardTap: (() -> ())? {
        get { return maskCropperView.onDiscardTap }
        set { maskCropperView.onDiscardTap = newValue }
    }
    
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? {
        get { return maskCropperView.onCroppingParametersChange }
        set { maskCropperView.onCroppingParametersChange = newValue }
    }
    
    func setImage(_ imageSource: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ()) {
        maskCropperView.setImage(imageSource, previewImage: previewImage, completion: completion)
    }
    
    func setCanvasSize(_ canvasSize: CGSize) {
        maskCropperView.setCanvasSize(canvasSize)
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        maskCropperView.setCroppingParameters(parameters)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        maskCropperView.setControlsEnabled(enabled)
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        maskCropperView.setTheme(theme)
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
