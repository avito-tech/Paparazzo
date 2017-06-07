import UIKit

/**
 * This is slightly modified Swift port of PhotoTweaks by Tu You
 * https://github.com/itouch2/PhotoTweaks
 */
final class PhotoTweakView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    
    private let scrollView = PhotoScrollView()
    private let gridView = GridView()
    private let croppingMask = ImageCroppingMask()
    
    // MARK: - State
    
    private var cropSize: CGSize = .zero
    private var originalSize: CGSize = .zero
    private var originalPoint: CGPoint = .zero
    private var manuallyZoomed: Bool = false
    
    // Угол поворота фотографии (кратно 90°), non-resettable
    private var turnAngle: CGFloat = 0
    // Угол наклона фотографии (меньше 90°), resettable
    private var tiltAngle: CGFloat = 0
    
    // Общий угол поворота фотки
    private var angle: CGFloat {
        return turnAngle + tiltAngle
    }
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.bounces = true
        scrollView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        
        gridView.isUserInteractionEnabled = false
        gridView.isHidden = true
        
        addSubview(scrollView)
        addSubview(gridView)
        addSubview(croppingMask)
        
        updateMasks()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            reset()
            calculateFrames()
            adjustRotation()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return scrollView
    }
    
    // MARK: - PhotoTweakView
    
    var cropAspectRatio = CGFloat(AspectRatio.defaultRatio.widthToHeightRatio()) {
        didSet {
            if cropAspectRatio != oldValue {
                calculateFrames()
            }
        }
    }
    
    var onCroppingParametersChange: ((ImageCroppingParameters) -> ())?
    
    func setImage(_ image: UIImage) {
        scrollView.imageView.image = image
        calculateFrames()
        notifyAboutCroppingParametersChange()
    }
    
    private func adjustRotation() {
        adjustRotation(contentOffsetCenter: contentOffsetCenter())
    }
    
    private func adjustRotation(contentOffsetCenter: CGPoint) {
        
        let width = fabs(cos(angle)) * cropSize.width + fabs(sin(angle)) * cropSize.height
        let height = fabs(sin(angle)) * cropSize.width + fabs(cos(angle)) * cropSize.height
        let center = scrollView.center
        
        let newBounds = CGRect(x: 0, y: 0, width: width, height: height)
        let newContentOffset = CGPoint(
            x: contentOffsetCenter.x - newBounds.size.width / 2,
            y: contentOffsetCenter.y - newBounds.size.height / 2
        )
        
        scrollView.transform = CGAffineTransform(rotationAngle: angle)
        scrollView.bounds = newBounds
        scrollView.center = center
        scrollView.contentOffset = newContentOffset
        
        // scale scroll view
        let shouldScale = scrollView.contentSize.width / scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0
        
        if !manuallyZoomed || shouldScale {
            
            scrollView.minimumZoomScale = scrollView.zoomScaleToBound()
            scrollView.zoomScale = scrollView.minimumZoomScale
            
            manuallyZoomed = false
        }
        
        checkScrollViewContentOffset()
        
        notifyAboutCroppingParametersChange()
    }
    
    private func contentOffsetCenter() -> CGPoint {
        return CGPoint(
            x: scrollView.contentOffset.x + scrollView.bounds.size.width / 2,
            y: scrollView.contentOffset.y + scrollView.bounds.size.height / 2
        )
    }
    
    func setCroppingParameters(_ parameters: ImageCroppingParameters) {
        
        scrollView.zoomScale = parameters.zoomScale
        manuallyZoomed = parameters.manuallyZoomed
        
        turnAngle = parameters.turnAngle
        tiltAngle = parameters.tiltAngle
        
        adjustRotation(contentOffsetCenter: parameters.contentOffsetCenter)
    }
    
    func setTiltAngle(_ angleInRadians: Float) {
        tiltAngle = CGFloat(angleInRadians)
        adjustRotation()
    }
    
    func turnCounterclockwise() {
        turnAngle += CGFloat(Float(-90).degreesToRadians())
        adjustRotation()
    }
    
    func photoTranslation() -> CGPoint {
        let imageViewBounds = scrollView.imageView.bounds
        let rect = scrollView.imageView.convert(imageViewBounds, to: self)
        let point = CGPoint(x: rect.midX, y: rect.midY)
        let zeroPoint = bounds.center
        return CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
    }
    
    func setGridVisible(_ visible: Bool) {
        gridView.isHidden = !visible
    }
    
    func setMaskVisible(_ visible: Bool) {
        croppingMask.isHidden = !visible
    }
    
    func cropPreviewImage() -> CGImage? {
        
        // Hide grid for it to be hidden on preview image
        let gridWasHidden = gridView.isHidden
        gridView.isHidden = true
        
        let previewImage = snapshot().flatMap { snapshot -> CGImage? in
            
            let cropRect = CGRect(
                x: (bounds.left + (bounds.size.width - cropSize.width) / 2) * snapshot.scale,
                y: (bounds.top + (bounds.size.height - cropSize.height) / 2) * snapshot.scale,
                width: cropSize.width * snapshot.scale,
                height: cropSize.height * snapshot.scale
            )
            
            return snapshot.cgImage.flatMap { $0.cropping(to: cropRect) }
        }
        
        gridView.isHidden = gridWasHidden
        
        return previewImage
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        manuallyZoomed = true
        notifyAboutCroppingParametersChange()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            notifyAboutCroppingParametersChange()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        notifyAboutCroppingParametersChange()
    }
    
    // MARK: - Private
    
    // layoutSubviews will be called each time scrollView rotates, but we don't want it
    private func calculateFrames() {
        
        guard let image = scrollView.imageView.image, width > 0 && height > 0 else {
            return
        }
        
        // scale the image
        cropSize = CGSize(
            width: bounds.size.width,
            height: bounds.size.width / cropAspectRatio
        )
        
        // size crop area to fit bounds
        if cropSize.height > bounds.size.height {
            cropSize = cropSize.scaled(bounds.size.height / cropSize.height)
        }
        
        let scaleX = image.size.width / cropSize.width
        let scaleY = image.size.height / cropSize.height
        let scale = min(scaleX, scaleY)     // get minimum scale to fill canvas with image
        
        let minZoomBounds = CGRect(
            x: 0,
            y: 0,
            width: image.size.width / scale,
            height: image.size.height / scale
        )
        
        originalSize = minZoomBounds.size
        
        scrollView.bounds = minZoomBounds
        scrollView.center = center
        scrollView.contentSize = scrollView.bounds.size
        
        scrollView.imageView.frame = scrollView.bounds
        
        gridView.bounds = CGRect(origin: .zero, size: cropSize)
        gridView.center = center
        
        croppingMask.bounds = frame
        
        originalPoint = convert(scrollView.center, to: self)
        
        updateMasks()
    }
    
    private func updateMasks(animated: Bool = false) {
        
        let animation = {
            self.croppingMask.performLayoutUpdate(with: self.cropSize)
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: animation)
        } else {
            animation()
        }
    }
    
    private func checkScrollViewContentOffset() {
        
        scrollView.contentOffset.x = max(scrollView.contentOffset.x, 0)
        scrollView.contentOffset.y = max(scrollView.contentOffset.y, 0)
        
        if scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.bounds.size.height {
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.bounds.size.height
        }
        
        if scrollView.contentSize.width - scrollView.contentOffset.x <= scrollView.bounds.size.width {
            scrollView.contentOffset.x = scrollView.contentSize.width - scrollView.bounds.size.width
        }
    }
    
    private func reset() {
        scrollView.transform = .identity
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
    }
    
    private func notifyAboutCroppingParametersChange() {
        onCroppingParametersChange?(croppingParameters())
    }
    
    private func croppingParameters() -> ImageCroppingParameters {
        
        var transform = CGAffineTransform.identity
        
        // translate
        let translation = photoTranslation()
        transform = transform.translatedBy(x: translation.x, y: translation.y)
        
        // rotate
        transform = transform.rotated(by: angle)
        
        // scale
        let t = scrollView.imageView.transform
        let xScale = sqrt(t.a * t.a + t.c * t.c)
        let yScale = sqrt(t.b * t.b + t.d * t.d)
        transform = transform.scaledBy(x: xScale, y: yScale)
        
        let parameters = ImageCroppingParameters(
            transform: transform,
            sourceSize: scrollView.imageView.image?.size ?? .zero,
            sourceOrientation: scrollView.imageView.image?.imageOrientation.exifOrientation ?? .up,
            outputWidth: scrollView.imageView.image?.size.width ?? 0,
            cropSize: cropSize,
            imageViewSize: scrollView.imageView.bounds.size,
            contentOffsetCenter: contentOffsetCenter(),
            turnAngle: turnAngle,
            tiltAngle: tiltAngle,
            zoomScale: scrollView.zoomScale,
            manuallyZoomed: manuallyZoomed
        )
        
        return parameters
    }
}

private class PhotoScrollView: UIScrollView {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = false
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func zoomScaleToBound() -> CGFloat {
        if imageView.bounds.size.width > 0 && imageView.bounds.size.height > 0 {
            let widthScale = bounds.size.width / imageView.bounds.size.width
            let heightScale = bounds.size.height / imageView.bounds.size.height
            return max(widthScale, heightScale)
        } else {
            return 1
        }
    }
}
