import UIKit

final class ImageCroppingViewController: UIViewController, ImageCroppingViewInput {
    
    private let imageCroppingView = ImageCroppingView()
    
    // MARK: - UIViewController
    
    override func loadView() {
        view = imageCroppingView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - ImageCroppingViewInput
    
    var onDiscardButtonTap: (() -> ())? {
        get { return imageCroppingView.onDiscardButtonTap }
        set { imageCroppingView.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: ((_ previewImage: CGImage?) -> ())? {
        get { return imageCroppingView.onConfirmButtonTap }
        set { imageCroppingView.onConfirmButtonTap = newValue }
    }
    
    var onAspectRatioButtonTap: (() -> ())? {
        get { return imageCroppingView.onAspectRatioButtonTap }
        set { imageCroppingView.onAspectRatioButtonTap = newValue }
    }
    
    var onRotationAngleChange: ((Float) -> ())? {
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
    
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())? {
        get { return imageCroppingView.onCroppingParametersChange }
        set { imageCroppingView.onCroppingParametersChange = newValue }
    }
    
    func setImage(_ image: ImageSource, previewImage: ImageSource?, completion: @escaping () -> ()) {
        imageCroppingView.setImage(image, previewImage: previewImage, completion: completion)
    }
    
    func setImageTiltAngle(_ angle: Float) {
        imageCroppingView.setImageTiltAngle(angle)
    }

    func turnImageCounterclockwise() {
        imageCroppingView.turnCounterclockwise()
    }

    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        imageCroppingView.setCroppingParameters(parameters)
    }
    
    func setRotationSliderValue(_ value: Float) {
        imageCroppingView.setRotationSliderValue(value)
    }
    
    func setCanvasSize(_ size: CGSize) {
        imageCroppingView.setCanvasSize(size)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        imageCroppingView.setControlsEnabled(enabled)
    }
    
    @nonobjc func setTitle(_ title: String) {
        imageCroppingView.setTitle(title)
    }

    func setAspectRatio(_ aspectRatio: AspectRatio) {
        imageCroppingView.setAspectRatio(aspectRatio)
    }
    
    func setAspectRatioButtonTitle(_ title: String) {
        imageCroppingView.setAspectRatioButtonTitle(title)
    }
    
    func setMinimumRotation(degrees: Float) {
        imageCroppingView.setMinimumRotation(degrees)
    }
    
    func setMaximumRotation(degrees: Float) {
        imageCroppingView.setMaximumRotation(degrees)
    }
    
    func setCancelRotationButtonTitle(_ title: String) {
        imageCroppingView.setCancelRotationButtonTitle(title)
    }
    
    func setCancelRotationButtonVisible(_ visible: Bool) {
        imageCroppingView.setCancelRotationButtonVisible(visible)
    }
    
    func setGridVisible(_ visible: Bool) {
        imageCroppingView.setGridVisible(visible)
    }
    
    func setGridButtonSelected(_ selected: Bool) {
        // TODO
    }
    
    // MARK: - ImageCroppingViewController
    
    func setTheme(_ theme: ImageCroppingUITheme) {
        imageCroppingView.setTheme(theme)
    }
    
    // MARK: - Dispose bag
    
    private var disposables = [AnyObject]()
    
    func addDisposable(_ object: AnyObject) {
        disposables.append(object)
    }
}
