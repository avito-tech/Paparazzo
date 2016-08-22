import UIKit
import AvitoDesignKit

final class ImageCroppingViewController: UIViewController, ImageCroppingViewInput {
    
    private let imageCroppingView = ImageCroppingView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = imageCroppingView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    // MARK: - ImageCroppingViewInput
    
    var onDiscardButtonTap: (() -> ())? {
        get { return imageCroppingView.onDiscardButtonTap }
        set { imageCroppingView.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: ((previewImage: CGImage?) -> ())? {
        get { return imageCroppingView.onConfirmButtonTap }
        set { imageCroppingView.onConfirmButtonTap = newValue }
    }
    
    var onAspectRatioButtonTap: (() -> ())? {
        get { return imageCroppingView.onAspectRatioButtonTap }
        set { imageCroppingView.onAspectRatioButtonTap = newValue }
    }
    
    var onRotationAngleChange: (Float -> ())? {
        get { return imageCroppingView.onRotationAngleChange }
        set { imageCroppingView.onRotationAngleChange = newValue }
    }
    
    var onRotateButtonTap: (() -> ())? {
        get { return imageCroppingView.onRotateButtonTap }
        set { imageCroppingView.onRotateButtonTap = newValue }
    }
    
    var onRotationCancelButtonTap: (() -> ())? {
        get { return imageCroppingView.onRotationCancelButtonTap }
        set { imageCroppingView.onRotationCancelButtonTap = newValue }
    }
    
    var onGridButtonTap: (() -> ())? {
        get { return imageCroppingView.onGridButtonTap }
        set { imageCroppingView.onGridButtonTap = newValue }
    }
    
    var onCroppingParametersChange: (ImageCroppingParameters -> ())? {
        get { return imageCroppingView.onCroppingParametersChange }
        set { imageCroppingView.onCroppingParametersChange = newValue }
    }
    
    func setImage(image: ImageSource, completion: (() -> ())) {
        imageCroppingView.setImage(image, completion: completion)
    }
    
    func setImageTiltAngle(angle: Float) {
        imageCroppingView.setImageTiltAngle(angle)
    }

    func turnImageCounterclockwise() {
        imageCroppingView.turnCounterclockwise()
    }

    func setCroppingParameters(parameters: ImageCroppingParameters) {
        imageCroppingView.setCroppingParameters(parameters)
    }
    
    func setRotationSliderValue(value: Float) {
        imageCroppingView.setRotationSliderValue(value)
    }
    
    func setCanvasSize(size: CGSize) {
        imageCroppingView.setCanvasSize(size)
    }
    
    func setControlsEnabled(enabled: Bool) {
        imageCroppingView.setControlsEnabled(enabled)
    }
    
    @nonobjc func setTitle(title: String) {
        imageCroppingView.setTitle(title)
    }

    func setAspectRatio(aspectRatio: AspectRatio) {
        imageCroppingView.setAspectRatio(aspectRatio)
    }
    
    func setAspectRatioButtonTitle(title: String) {
        imageCroppingView.setAspectRatioButtonTitle(title)
    }
    
    func setMinimumRotation(degrees: Float) {
        imageCroppingView.setMinimumRotation(degrees)
    }
    
    func setMaximumRotation(degrees: Float) {
        imageCroppingView.setMaximumRotation(degrees)
    }
    
    func setCancelRotationButtonTitle(title: String) {
        imageCroppingView.setCancelRotationButtonTitle(title)
    }
    
    func setCancelRotationButtonVisible(visible: Bool) {
        imageCroppingView.setCancelRotationButtonVisible(visible)
    }
    
    func setGridVisible(visible: Bool) {
        imageCroppingView.setGridVisible(visible)
    }
    
    func setGridButtonSelected(selected: Bool) {
        // TODO
    }
    
    // MARK: - ImageCroppingViewController
    
    func setTheme(theme: ImageCroppingUITheme) {
        imageCroppingView.setTheme(theme)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(object: AnyObject) {
        disposables.append(object)
    }
}
