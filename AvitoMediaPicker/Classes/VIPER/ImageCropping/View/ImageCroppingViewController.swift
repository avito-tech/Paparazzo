import UIKit

final class ImageCroppingViewController: UIViewController, ImageCroppingViewInput {
    
    private let imageCroppingView = ImageCroppingView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = imageCroppingView
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
    
    var onConfirmButtonTap: (() -> ())? {
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
    
    func setImage(image: ImageSource) {
        imageCroppingView.setImage(image)
    }
    
    func setImageRotation(angle: Float) {
        imageCroppingView.setImageRotation(CGFloat(angle))
    }
    
    func setRotationSliderValue(value: Float) {
        imageCroppingView.setRotationSliderValue(value)
    }
    
    func rotateImageByAngle(angle: Float) {
        // TODO
    }
    
    @nonobjc func setTitle(title: String) {
        imageCroppingView.setTitle(title)
    }
    
    func setAspectRatioButtonMode(mode: AspectRatioMode) {
        imageCroppingView.setAspectRatioButtonMode(mode)
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
    
    func showStencilForAspectRatioMode(mode: AspectRatioMode) {
        imageCroppingView.showStencilForAspectRatioMode(mode)
    }
    
    func hideStencil() {
        imageCroppingView.hideStencil()
    }
    
    func setCancelRotationButtonTitle(title: String) {
        imageCroppingView.setCancelRotationButtonTitle(title)
    }
    
    func setCancelRotationButtonVisible(visible: Bool) {
        imageCroppingView.setCancelRotationButtonVisible(visible)
    }
    
    func setGridVisible(visible: Bool) {
        // TODO
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
