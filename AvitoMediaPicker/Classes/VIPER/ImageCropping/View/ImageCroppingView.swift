import UIKit
import AvitoDesignKit

final class ImageCroppingView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    
    /// Вьюха, которая показывается до того, как будет доступна полная картинка для редактирования (чтобы избежать моргания)
    private let splashView = UIImageView()
    
    private let previewView = PhotoTweakView()
    private let controlsView = ImageCroppingControlsView()
    private let aspectRatioButton = UIButton()
    private let titleLabel = UILabel()
    
    // MARK: - Constants
    
    private let controlsMinHeight: CGFloat = {
        let iPhone5ScreenSize = CGSize(width: 320, height: 568)
        return iPhone5ScreenSize.height - iPhone5ScreenSize.width / 0.75
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .whiteColor()
        clipsToBounds = true
        
        aspectRatioButton.layer.borderWidth = 1
        aspectRatioButton.setTitleColor(.blackColor(), forState: .Normal)
        aspectRatioButton.addTarget(
            self,
            action: #selector(onAspectRatioButtonTap(_:)),
            forControlEvents: .TouchUpInside
        )
        
        controlsView.onConfirmButtonTap = { [weak self] in
            self?.onConfirmButtonTap?(previewImage: self?.previewView.cropPreviewImage())
        }
        
        splashView.contentMode = .ScaleAspectFill
        
        addSubview(previewView)
        addSubview(splashView)
        addSubview(controlsView)
        addSubview(titleLabel)
        addSubview(aspectRatioButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        aspectRatioButton.top = 14
        aspectRatioButton.right = bounds.right - 12
        
        titleLabel.resizeToFitWidth(bounds.size.width - 2 * (bounds.right - aspectRatioButton.left))
        titleLabel.centerX = bounds.centerX
        titleLabel.top = 13
        
        controlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: max(controlsMinHeight, bounds.size.height - bounds.size.width / 0.75)   // оставляем вверху место под фотку 3:4
        )
        
        previewView.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            bottom: controlsView.top
        )
        
        layoutSplashView()
    }
    
    private func layoutSplashView() {
        
        let height: CGFloat
        
        switch aspectRatio {
        case .portrait_3x4:
            height = bounds.size.width * 4 / 3
        case .landscape_4x3:
            height = bounds.size.width * 3 / 4
        }
        
        let scaleToFit = min(1, previewView.height / height)
        
        splashView.size = CGSize(width: bounds.size.width, height: height).scaled(scaleToFit)
        splashView.center = previewView.center
    }
    
    // MARK: - ImageCroppingView
    
    var onDiscardButtonTap: (() -> ())? {
        get { return controlsView.onDiscardButtonTap }
        set { controlsView.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: ((previewImage: CGImage?) -> ())?
    
    var onRotationAngleChange: (Float -> ())? {
        get { return controlsView.onRotationAngleChange }
        set { controlsView.onRotationAngleChange = newValue }
    }
    
    var onRotateButtonTap: (() -> ())? {
        get { return controlsView.onRotateButtonTap }
        set { controlsView.onRotateButtonTap = newValue }
    }
    
    var onRotationCancelButtonTap: (() -> ())? {
        get { return controlsView.onRotationCancelButtonTap }
        set { controlsView.onRotationCancelButtonTap = newValue }
    }
    
    var onGridButtonTap: (() -> ())? {
        get { return controlsView.onGridButtonTap }
        set { controlsView.onGridButtonTap = newValue }
    }
    
    var onAspectRatioButtonTap: (() -> ())?
    
    var onCroppingParametersChange: (ImageCroppingParameters -> ())? {
        get { return previewView.onCroppingParametersChange }
        set { previewView.onCroppingParametersChange = newValue }
    }
    
    func setImage(image: ImageSource, previewImage: ImageSource?, completion: (() -> ())?) {
        
        if let previewImage = previewImage {
            
            let screenSize = UIScreen.mainScreen().bounds.size
            let previewOptions = ImageRequestOptions(size: .FitSize(screenSize), deliveryMode: .Progressive)
            
            splashView.hidden = false
            
            previewImage.requestImage(options: previewOptions) { [weak self] (result: ImageRequestResult<UIImage>) in
                if let image = result.image where self?.splashView.hidden == false {
                    self?.splashView.image = image
                }
            }
        }
        
        let options = ImageRequestOptions(size: .FitSize(sourceImageMaxSize), deliveryMode: .Best)
        
        image.requestImage(options: options) { [weak self] (result: ImageRequestResult<UIImage>) in
            if let image = result.image {
                self?.previewView.setImage(image)
                self?.splashView.hidden = true
                self?.splashView.image = nil
            }
            completion?()
        }
    }
    
    func setImageTiltAngle(angle: Float) {
        previewView.setTiltAngle(angle.degreesToRadians())
    }

    func turnCounterclockwise() {
        previewView.turnCounterclockwise()
    }
    
    func setCroppingParameters(parameters: ImageCroppingParameters) {
        previewView.setCroppingParameters(parameters)
    }
    
    func setRotationSliderValue(value: Float) {
        controlsView.setRotationSliderValue(value)
    }
    
    func setCanvasSize(size: CGSize) {
        sourceImageMaxSize = size
    }
    
    func setControlsEnabled(enabled: Bool) {
        controlsView.setControlsEnabled(enabled)
        aspectRatioButton.enabled = enabled
    }
    
    func setTheme(theme: ImageCroppingUITheme) {
        controlsView.setTheme(theme)
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setAspectRatio(aspectRatio: AspectRatio) {
        
        self.aspectRatio = aspectRatio
        
        aspectRatioButton.size = aspectRatioButtonSize()
        previewView.cropAspectRatio = CGFloat(aspectRatio.widthToHeightRatio())
        
        switch aspectRatio {
        
        case .portrait_3x4:
            
            titleLabel.textColor = .whiteColor()
            
            aspectRatioButton.setTitleColor(.whiteColor(), forState: .Normal)
            aspectRatioButton.layer.borderColor = UIColor.whiteColor().CGColor
            
            setShadowVisible(true, forView: titleLabel)
            setShadowVisible(true, forView: aspectRatioButton)
        
        case .landscape_4x3:
            
            titleLabel.textColor = .blackColor()
            
            aspectRatioButton.setTitleColor(.blackColor(), forState: .Normal)
            aspectRatioButton.layer.borderColor = UIColor.blackColor().CGColor
            
            setShadowVisible(false, forView: titleLabel)
            setShadowVisible(false, forView: aspectRatioButton)
        }
        
        layoutSplashView()
    }
    
    func setAspectRatioButtonTitle(title: String) {
        aspectRatioButton.setTitle(title, forState: .Normal)
    }
    
    func setMinimumRotation(degrees: Float) {
        controlsView.setMinimumRotation(degrees)
    }
    
    func setMaximumRotation(degrees: Float) {
        controlsView.setMaximumRotation(degrees)
    }
    
    func setCancelRotationButtonTitle(title: String) {
        controlsView.setCancelRotationButtonTitle(title)
    }
    
    func setCancelRotationButtonVisible(visible: Bool) {
        controlsView.setCancelRotationButtonVisible(visible)
    }
    
    func setGridVisible(visible: Bool) {
        previewView.setGridVisible(visible)
    }
    
    // MARK: - Private
    
    private var aspectRatio: AspectRatio = .portrait_3x4
    
    /// Максимальный размер оригинальной картинки. Если меньше размера самой картинки, она будет даунскейлиться.
    private var sourceImageMaxSize = CGSize(width: CGFloat.max, height: CGFloat.max)
    
    private func aspectRatioButtonSize() -> CGSize {
        switch aspectRatio {
        case .portrait_3x4:
            return CGSize(width: 34, height: 42)
        case .landscape_4x3:
            return CGSize(width: 42, height: 34)
        }
    }

    private func setShadowVisible(visible: Bool, forView view: UIView) {
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = visible ? 0.5 : 0
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
    }
    
    @objc private func onAspectRatioButtonTap(sender: UIButton) {
        onAspectRatioButtonTap?()
    }
}