import UIKit

final class PhotoTweakView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    private let scrollView = PhotoScrollView()
    private let cropView = UIView()
    private let topMask = UIView()
    private let bottomMask = UIView()
    
    private var originalSize: CGSize = .zero
    private var angle: CGFloat = 0
    private var manualZoomed: Bool = false
    
    private var maximumCanvasSize: CGSize = .zero
    private var _centerY: CGFloat = 0
    private var originalPoint: CGPoint = .zero
    
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
        addSubview(cropView)
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
    
    func setImage(image: UIImage) {
        scrollView.imageView.image = image
        calculateFrames()
    }
    
    func setImageRotation(angle: CGFloat) {
        
        updateMasks()
        
        // rotate scroll view
        self.angle = angle;
        self.scrollView.transform = CGAffineTransformMakeRotation(self.angle)
        
        // position scroll view
        let width = fabs(cos(self.angle)) * self.cropView.frame.size.width + fabs(sin(self.angle)) * self.cropView.frame.size.height
        let height = fabs(sin(self.angle)) * self.cropView.frame.size.width + fabs(cos(self.angle)) * self.cropView.frame.size.height
        let center = self.scrollView.center
        
        let contentOffset = self.scrollView.contentOffset
        let contentOffsetCenter = CGPointMake(contentOffset.x + self.scrollView.bounds.size.width / 2, contentOffset.y + self.scrollView.bounds.size.height / 2)
        self.scrollView.bounds = CGRectMake(0, 0, width, height)
        let newContentOffset = CGPointMake(contentOffsetCenter.x - self.scrollView.bounds.size.width / 2, contentOffsetCenter.y - self.scrollView.bounds.size.height / 2)
        self.scrollView.contentOffset = newContentOffset
        self.scrollView.center = center
        
        // scale scroll view
        let shouldScale = self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 || self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0
        
        if !self.manualZoomed || shouldScale {
            self.scrollView.setZoomScale(self.scrollView.zoomScaleToBound(), animated: false)
            self.scrollView.minimumZoomScale = self.scrollView.zoomScaleToBound()
            
            self.manualZoomed = false
        }
        
        checkScrollViewContentOffset()

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
        
        let aspectRatio = CGFloat(4.0 / 3.0)
        
        // scale the image
        maximumCanvasSize = CGSizeMake(
            self.frame.size.width,
            self.frame.size.width / aspectRatio
        )
        
        let scaleX = image.size.width / maximumCanvasSize.width
        let scaleY = image.size.height / maximumCanvasSize.height
        let scale = max(scaleX, scaleY)
        let bounds = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale)
        
        originalSize = bounds.size
        _centerY = maximumCanvasSize.height / 2
        
        scrollView.bounds = bounds
        scrollView.center = self.center
        scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)
        
        scrollView.imageView.frame = self.scrollView.bounds
        
        cropView.bounds = self.scrollView.frame
        cropView.center = self.scrollView.center
        
        originalPoint = convertPoint(self.scrollView.center, toView: self)
    }
    
    private func updateMasks(animated animated: Bool = false) {
        
        let animation = {
            
            self.topMask.frame = CGRect(
                x: 0,
                y: 0,
                width: self.cropView.frame.origin.x + self.cropView.frame.size.width,
                height: self.cropView.frame.origin.y
            )
            
            self.bottomMask.frame = CGRect(
                x: self.cropView.frame.origin.x,
                y: self.cropView.frame.origin.y + self.cropView.frame.size.height,
                width: self.frame.size.width - self.cropView.frame.origin.x,
                height: self.frame.size.height - (self.cropView.frame.origin.y + self.cropView.frame.size.height)
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