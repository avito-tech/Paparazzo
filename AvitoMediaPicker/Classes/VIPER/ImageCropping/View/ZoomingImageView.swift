import UIKit

// TODO: временная штука, надо будет ее заменить на что-то более хитрое, вроде CATiledLayer
final class ZoomingImageView: UIView {
    
    private let scrollView = ZoomingImageScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
    }
    
    var image: UIImage? {
        get { return scrollView.image }
        set { scrollView.image = newValue }
    }
    
    func setImageRotation(angle: CGFloat) {
        scrollView.imageView.setImageRotation(angle)
    }
}

private class ZoomingImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    private var image: UIImage? {
        get { return imageView.image }
        set {
            zoomScale = 1
            
            imageView.image = newValue
            imageView.sizeToFit()
            
            configureForCurrentImageSize()
        }
    }
    
    // MARK: - Subviews
    
    private let imageView = ImageViewWrapper()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollViewDecelerationRateFast
        delegate = self
        
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // center image view as it becomes smaller than the size of the screen
        
        var imageFrame = imageView.frame
        
        // center horizontally
        if imageFrame.size.width < bounds.size.width {
            imageFrame.origin.x = (bounds.size.width - imageFrame.size.width) / 2
        } else {
            imageFrame.origin.x = 0
        }
        
        // center vertically
        if imageFrame.size.height < bounds.size.height {
            imageFrame.origin.y = (bounds.size.height - imageFrame.size.height) / 2
        } else {
            imageFrame.origin.y = 0
        }
        
        imageView.frame = imageFrame
    }
    
    override var frame: CGRect {
        willSet {
            if newValue.size != frame.size {
                prepareForResize()
            }
        }
        didSet {
            if frame.size != oldValue.size {
                recoverFromResizing()
            }
        }
    }
    
    // MARK: - Configure scrollView to display new image
    
    private var imageSize: CGSize {
        return imageView.image?.size ?? .zero
    }
    
    private func configureForCurrentImageSize() {
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale
    }
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        
        let imageSize = self.imageSize
        
        var minScale = max(
            bounds.size.width  / imageSize.width,   // the scale needed to perfectly fit the image width-wise
            bounds.size.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
        )
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
        let maxScale = CGFloat(1) / UIScreen.mainScreen().scale
        
        // don't let minScale exceed maxScale (if the image is smaller than the screen,
        // we don't want to force it to be zoomed)
        if (minScale > maxScale) {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        print("min scale = \(minScale), max scale = \(maxScale)")
    }
    
    // MARK: - Rotation support
    
    private var pointToCenterAfterResize = CGPoint.zero
    private var scaleToRestoreAfterResize = CGFloat(1)
    
    private func prepareForResize() {
        
        pointToCenterAfterResize = convertPoint(bounds.center, toView: imageView)
        scaleToRestoreAfterResize = zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(FLT_EPSILON) {
            scaleToRestoreAfterResize = 0
        }
    }
    
    private func recoverFromResizing() {
        
        setMaxMinZoomScalesForCurrentBounds()
        
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)
        
        // Step 2: restore center point, first making sure it is within the allowable range.
        
        // 2a: convert our desired center point back to our own coordinate space
        let boundsCenter = convertPoint(pointToCenterAfterResize, fromView: imageView)
        
        // 2b: calculate the content offset that would yield that center point
        var offset = CGPoint(
            x: bounds.centerX - bounds.size.width / 2,
            y: bounds.centerY - bounds.size.height / 2
        )
        
        // 2c: restore offset, adjusted to be within the allowable range
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        
        let realMaxOffsetX = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffsetX)
        
        let realMaxOffsetY = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffsetY)
        
        contentOffset = offset
    }
    
    private func minimumContentOffset() -> CGPoint {
        return .zero
    }
    
    private func maximumContentOffset() -> CGPoint {
        return CGPoint(
            x: contentSize.width - bounds.size.width,
            y: contentSize.height - bounds.size.height
        )
    }
    
    // MARK: - UIScrollViewDelegate
    
    @objc func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}