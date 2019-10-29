import UIKit

extension UIView {
    
    final var size: CGSize  {
        @inline(__always) get { return frame.size }
        @inline(__always) set { frame.size = newValue }
    }
    
    final var origin: CGPoint {
        @inline(__always) get { return frame.origin }
        @inline(__always) set { frame.origin = newValue }
    }
    
    final var width: CGFloat {
        @inline(__always) get { return size.width }
        @inline(__always) set { size.width = newValue }
    }
    
    final var height: CGFloat {
        @inline(__always) get { return size.height }
        @inline(__always) set { size.height = newValue }
    }
    
    final var x: CGFloat {
        @inline(__always) get { return origin.x }
        @inline(__always) set { origin.x = newValue }
    }
    
    final var y: CGFloat {
        @inline(__always) get { return origin.y }
        @inline(__always) set { origin.y = newValue }
    }
    
    final var centerX: CGFloat {
        @inline(__always) get { return center.x }
        @inline(__always) set { x = newValue - width/2 }
    }
    
    final var centerY: CGFloat {
        @inline(__always) get { return center.y }
        @inline(__always) set { y = newValue - height/2 }
    }
    
    final var left: CGFloat {
        @inline(__always) get { return x }
        @inline(__always) set { x = newValue }
    }
    
    final var right: CGFloat {
        @inline(__always) get { return left + width }
        @inline(__always) set { left = newValue - width }
    }
    
    final var top: CGFloat {
        @inline(__always) get { return y }
        @inline(__always) set { y = newValue }
    }
    
    final var bottom: CGFloat {
        @inline(__always) get { return top + height }
        @inline(__always) set { top = newValue - height }
    }
    
    func resizeToFitSize(_ size: CGSize) {
        self.size = sizeThatFits(size).intersection(size)
    }
    
    func resizeToFitWidth(_ width: CGFloat) {
        resizeToFitSize(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    func sizeForWidth(_ width: CGFloat) -> CGSize {
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        return sizeThatFits(maxSize).intersectionWidth(width)
    }
    
    func sizeThatFits() -> CGSize {
        // Returns same size as view gets after sizeToFit(): desired size without restrictions
        return sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude))
    }
    
    func setAnchorPointPreservingFrame(anchorPoint: CGPoint) {
        
        var newPoint = CGPoint(
            x: bounds.size.width * anchorPoint.x,
            y: bounds.size.height * anchorPoint.y
        )
        
        var oldPoint = CGPoint(
            x: bounds.size.width * layer.anchorPoint.x,
            y: bounds.size.height * layer.anchorPoint.y
        )
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        layer.position = CGPoint(
            x: layer.position.x - oldPoint.x + newPoint.x,
            y: layer.position.y - oldPoint.y + newPoint.y
        )
        
        layer.anchorPoint = anchorPoint
    }
    
    func snapshot(withScale scale: CGFloat = 0) -> UIImage? {

        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                self.layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
            
            if let context = UIGraphicsGetCurrentContext() {
                self.layer.render(in: context)
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    func removeFromSuperviewAfterFadingOut(withDuration duration: TimeInterval) {
        
        UIView.animate(
            withDuration: duration,
            animations: {
                self.alpha = 0
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }
    
    func setAccessibilityId(_ id: AccessibilityId) {
        setAccessibilityId(id.rawValue)
    }
    
    func setAccessibilityId(_ identifier: String) {
        accessibilityIdentifier = identifier
        isAccessibilityElement = true
    }
}

extension UICollectionView {
    
    func performBatchUpdates(updates: @escaping () -> Void) {
        performBatchUpdates(updates, completion: nil)
    }
    
    func performNonAnimatedBatchUpdates(updates: @escaping () -> Void, completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: 0) { 
            self.performBatchUpdates(updates, completion: completion)
        }
    }
    
    func performBatchUpdates(animated: Bool, updates: @escaping () -> Void, completion: ((Bool) -> ())? = nil) {
        let updateCollectionView = animated ? performBatchUpdates : performNonAnimatedBatchUpdates
        updateCollectionView(updates, completion)
    }
    
    func insertItems(animated: Bool, _ updates: @escaping () -> [IndexPath]?) {
        performBatchUpdates(animated: animated, updates: { [weak self] in
            if let indexPaths = updates() {
                self?.insertItems(at: indexPaths)
            }
        })
    }
    
    func deleteItems(animated: Bool, _ updates: @escaping () -> [IndexPath]?) {
        performBatchUpdates(animated: animated, updates: { [weak self] in
            if let indexPaths = updates() {
                self?.deleteItems(at: indexPaths)
            }
        })
    }
}

extension UIImage {
    
    static func imageWithColor(_ color: UIColor, imageSize: CGSize) -> UIImage? {
        
        let imageBounds = CGRect(origin: .zero, size: imageSize)
        
        let drawInContext = { (context: CGContext) in
            context.setFillColor(color.cgColor)
            context.fill(imageBounds)
        }
        
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: imageBounds)
            return renderer.image { rendererContext in
                drawInContext(rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(imageSize)
            guard let currentContext = UIGraphicsGetCurrentContext() else { return nil }
            drawInContext(currentContext)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return result
        }
    }
    
    func scaled(scale: CGFloat) -> UIImage? {
        return cgImage?.scaled(scale).flatMap { UIImage(cgImage: $0) }
    }
    
    func resized(toFit size: CGSize) -> UIImage? {
        return cgImage?.resized(toFit: size).flatMap { UIImage(cgImage: $0) }
    }
    
    func resized(toFill size: CGSize) -> UIImage? {
        return cgImage?.resized(toFill: size).flatMap { UIImage(cgImage: $0) }
    }
}

extension UIColor {
    
    static func RGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    static func RGBS(rgb: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: rgb/255, green: rgb/255, blue: rgb/255, alpha: alpha)
    }
}

extension UIEdgeInsets {
    
    var width: CGFloat {
        return left + right
    }
    
    var height: CGFloat {
        return top + bottom
    }
}
