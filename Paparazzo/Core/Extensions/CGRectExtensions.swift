import CoreGraphics

extension CGRect {
    
    var x: CGFloat {
        get { return origin.x }
        set { origin.x = newValue }
    }
    var y: CGFloat {
        get { return origin.y }
        set { origin.y = newValue }
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x: centerX, y: centerY)
        }
        set {
            centerX = newValue.x
            centerY = newValue.y
        }
    }
    
    var centerX: CGFloat {
        get { return x + width/2 }
        set { x = newValue - width/2 }
    }
    
    var centerY: CGFloat {
        get { return y + height/2 }
        set { y = newValue - height/2 }
    }
    
    var left: CGFloat {
        get { return x }
        set { x = newValue }
    }
    
    var right: CGFloat {
        get { return left + width }
        set { left = newValue - width }
    }
    
    var top: CGFloat {
        get { return y }
        set { y = newValue }
    }
    
    var bottom: CGFloat {
        get { return top + height }
        set { top = newValue - height }
    }
    
    init(left: CGFloat, right: CGFloat, top: CGFloat, height: CGFloat) {
        self.init(x: left, y: top, width: right - left, height: height)
    }
    
    init(left: CGFloat, right: CGFloat, bottom: CGFloat, height: CGFloat) {
        self.init(x: left, y: bottom - height, width: right - left, height: height)
    }
    
    // Возвращает прямоугольник, повернутый относительно исходного на угол angle и описанный
    // вокруг него (все вершины исходного прямоугольника лежат на сторонах искомого).
    // Результат описан в повернутой системе координат.
    func enclosingRectRotatedBy(angle: CGFloat) -> CGRect {
        
        let newSize = CGSize(
            width: size.width * cos(angle) + size.height * sin(angle),
            height: size.width * sin(angle) + size.height * cos(angle)
        )
        
        let origin = CGPoint(
            x: center.x - newSize.width / 2,
            y: center.y - newSize.height / 2
        )
        
        return CGRect(origin: origin, size: newSize)
    }
    
    func cornersByApplyingTransform(transform: CGAffineTransform)
        -> (topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        
        let offsetX = size.width / 2
        let offsetY = size.height / 2
        
        // Трансформация, переносящая центр rect'а в начало координат
        let moveToZeroTransform = CGAffineTransform(translationX: -offsetX, y: -offsetY)
        
        // Трансформация, которая будет преобразовывать расчитанные точки обратно в исходную систему координат
        let restorePositionTransform = CGAffineTransform(translationX: offsetX, y: offsetY)
        
        var transform = moveToZeroTransform.concatenating(transform)
        transform = transform.concatenating(restorePositionTransform)
        
        let topLeft = CGPoint(x: left, y: top)
        let topRight = CGPoint(x: right, y: top)
        let bottomRight = CGPoint(x: right, y: bottom)
        let bottomLeft = CGPoint(x: left, y: bottom)
        
        return (
            topLeft: topLeft.applying(transform),
            topRight: topRight.applying(transform),
            bottomRight: bottomRight.applying(transform),
            bottomLeft: bottomLeft.applying(transform)
        )
    }
}

extension CGSize {
    
    static let minimumTapAreaSize = CGSize(width: 44, height: 44)
    
    // Intersect two sizes (imagine intersection between two rectangles with x = width, y = height)
    // Resulting size will be smaller than self and other or equal
    func intersection(_ other: CGSize) -> CGSize {
        return CGSize(
            width: min(width, other.width),
            height: min(height, other.height)
        )
    }
    
    func intersectionWidth(_ width: CGFloat) -> CGSize {
        return CGSize(
            width: min(self.width, width),
            height: height
        )
    }
    
    func scaled(_ scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}
