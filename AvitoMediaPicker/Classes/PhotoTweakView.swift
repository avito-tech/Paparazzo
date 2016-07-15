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
            calculateFrames()
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        return scrollView
    }
    
    // MARK: - PhotoTweakView
    
    var cropAspectRatio: CGFloat = 4.0 / 3.0 {
        didSet {
            if cropAspectRatio != oldValue {
                let angle = self.angle
                setImageRotation(0)
                calculateFrames()
                setImageRotation(angle)
            }
        }
    }
    
    func setImage(image: UIImage) {
        scrollView.imageView.image = image
        calculateFrames()
    }
    
    func setImageRotation(angle: CGFloat) {
        
        self.angle = angle
        
        let newSize = CGSize(
            width: fabs(cos(angle)) * cropSize.width + fabs(sin(angle)) * cropSize.height,
            height: fabs(sin(angle)) * cropSize.width + fabs(cos(angle)) * cropSize.height
        )
        
        scrollView.setBoundsSizePreservingContentCenter(newSize)
        scrollView.transform = CGAffineTransformMakeRotation(angle)
        
        // scale scroll view
        let shouldScale = scrollView.contentSize.width / scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0
        
        if !manualZoomed || shouldScale {
            
            let zoomScale = scrollView.zoomScaleToBound()
            debugPrint("zoomScale = \(zoomScale)")
            
            scrollView.setZoomScale(zoomScale, animated: false)
            scrollView.minimumZoomScale = zoomScale
            
            manualZoomed = false
        }
        
        checkScrollViewContentOffset()
    }
    
    func rotate(by angle: CGFloat) {
        setImageRotation(self.angle + angle)
    }
    
    func photoTranslation() -> CGPoint {
        let rect = scrollView.imageView.convertRect(scrollView.imageView.bounds, toView: self)
        let point = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
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
    
    // We put this code in a separate function instead of layoutSubviews, because the latter will be called
    // each time scrollView rotates, but we don't want it
    private func calculateFrames() {
        
        guard let imageSize = scrollView.imageView.image?.size where width > 0 && height > 0 else {
            return
        }
        
        cropSize = CGSize(
            width: bounds.size.width,
            height: bounds.size.width / cropAspectRatio
        )
        
        // get minimum scale to fill canvas with image
        let scale = min(
            imageSize.width / cropSize.width,
            imageSize.height / cropSize.height
        )
        
        let minZoomBounds = CGRect(
            x: 0,
            y: 0,
            width: imageSize.width / scale,
            height: imageSize.height / scale
        )
        
        scrollView.setBoundsSizePreservingContentCenter(cropSize)
        scrollView.center = bounds.center
        scrollView.contentSize = minZoomBounds.size
        
        scrollView.imageView.frame = minZoomBounds
        
        originalPoint = convertPoint(scrollView.center, toView: self)
        originalSize = minZoomBounds.size
        
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