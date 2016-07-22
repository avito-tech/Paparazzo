import UIKit

/**
 * This is slightly modified Swift port of PhotoTweaks by Tu You
 * https://github.com/itouch2/PhotoTweaks
 */
final class PhotoTweakView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    private let scrollView = PhotoScrollView()
    private let topMask = UIView()
    private let bottomMask = UIView()
    
    private var cropSize: CGSize = .zero
    private var originalSize: CGSize = .zero
    private var originalPoint: CGPoint = .zero
    private var angle: CGFloat = 0
    private var manualZoomed: Bool = false
    
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
        
        let maskColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        topMask.backgroundColor = maskColor
        bottomMask.backgroundColor = maskColor
        
        addSubview(scrollView)
        addSubview(topMask)
        addSubview(bottomMask)
        
        updateMasks()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            reset()
            calculateFrames()
            setImageRotation(angle)
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return scrollView
    }
    
    // MARK: - PhotoTweakView
    
    var cropAspectRatio: CGFloat = 4.0 / 3.0 {
        didSet {
            if cropAspectRatio != oldValue {
                calculateFrames()
            }
        }
    }
    
    var onCroppingParametersChange: (ImageCroppingParameters -> ())?
    
    func setImage(image: UIImage) {
        scrollView.imageView.image = image
        calculateFrames()
    }
    
    func setImageRotation(angle: CGFloat) {
        
        self.angle = angle
        
        let width = fabs(cos(angle)) * cropSize.width + fabs(sin(angle)) * cropSize.height
        let height = fabs(sin(angle)) * cropSize.width + fabs(cos(angle)) * cropSize.height
        let center = scrollView.center
        
        let contentOffsetCenter = CGPoint(
            x: scrollView.contentOffset.x + scrollView.bounds.size.width / 2,
            y: scrollView.contentOffset.y + scrollView.bounds.size.height / 2
        )
        
        let newBounds = CGRect(x: 0, y: 0, width: width, height: height)
        let newContentOffset = CGPoint(
            x: contentOffsetCenter.x - newBounds.size.width / 2,
            y: contentOffsetCenter.y - newBounds.size.height / 2
        )
        
        scrollView.transform = CGAffineTransformMakeRotation(angle)
        scrollView.bounds = newBounds
        scrollView.center = center
        scrollView.contentOffset = newContentOffset
        
        // scale scroll view
        let shouldScale = scrollView.contentSize.width / scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0
        
        if !manualZoomed || shouldScale {
            
            scrollView.minimumZoomScale = scrollView.zoomScaleToBound()
            scrollView.zoomScale = scrollView.minimumZoomScale
            
            manualZoomed = false
        }
        
        checkScrollViewContentOffset()
        
        notifyAboutCroppingParametersChange()
    }
    
    func rotate(by angle: CGFloat) {
        setImageRotation(self.angle + angle)
    }
    
    func photoTranslation() -> CGPoint {
        let rect = scrollView.imageView.convertRect(scrollView.imageView.bounds, toView: self)
        let point = CGPoint(x: rect.midX, y: rect.midY)
        let zeroPoint = bounds.center
        return CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.scrollView.imageView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        manualZoomed = true
    }
    
    // MARK: - Private
    
    // layoutSubviews will be called each time scrollView rotates, but we don't want it
    private func calculateFrames() {
        
        guard let image = scrollView.imageView.image where width > 0 && height > 0 else {
            return
        }
        
        // scale the image
        cropSize = CGSize(
            width: bounds.size.width,
            height: bounds.size.width / cropAspectRatio
        )
        
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
        scrollView.center = self.center
        scrollView.contentSize = scrollView.bounds.size
        
        scrollView.imageView.frame = scrollView.bounds
        
        originalPoint = convertPoint(scrollView.center, toView: self)
        
        updateMasks()
    }
    
    private func updateMasks(animated animated: Bool = false) {
        
        let maskSize = CGSize(
            width: bounds.size.width,
            height: (bounds.size.height - cropSize.height) / 2
        )
        
        let animation = {
            self.topMask.frame = CGRect(
                origin: CGPoint(x: 0, y: self.bounds.top),
                size: maskSize
            )
            self.bottomMask.frame = CGRect(
                origin: CGPoint(x: 0, y: self.bounds.bottom - maskSize.height),
                size: maskSize
            )
        }
        
        if animated {
            UIView.animateWithDuration(0.25, animations: animation)
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
        scrollView.transform = CGAffineTransformIdentity
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
    }
    
    private func notifyAboutCroppingParametersChange() {
        onCroppingParametersChange?(croppingParameters())
    }
    
    private func croppingParameters() -> ImageCroppingParameters {
        
        var transform = CGAffineTransformIdentity
        
        // translate
        let translation = photoTranslation()
        transform = CGAffineTransformTranslate(transform, translation.x, translation.y)
        
        // rotate
        transform = CGAffineTransformRotate(transform, angle)
        
        // scale
        let t = scrollView.imageView.transform
        let xScale = sqrt(t.a * t.a + t.c * t.c)
        let yScale = sqrt(t.b * t.b + t.d * t.d)
        transform = CGAffineTransformScale(transform, xScale, yScale)
        
        return ImageCroppingParameters(
            transform: transform,
            sourceSize: scrollView.imageView.image?.size ?? .zero,
            sourceOrientation: scrollView.imageView.image?.imageOrientation.exifOrientation ?? .Up,
            outputWidth: scrollView.imageView.image?.size.width ?? 0,
            cropSize: cropSize,
            imageViewSize: scrollView.imageView.bounds.size
        )
    }
}

private class PhotoScrollView: UIScrollView {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.backgroundColor = .clearColor()
        imageView.userInteractionEnabled = false
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func zoomScaleToBound() -> CGFloat {
        var widthScale = bounds.size.width / imageView.bounds.size.width
        var heightScale = bounds.size.height / imageView.bounds.size.height
        return max(widthScale, heightScale)
    }
}