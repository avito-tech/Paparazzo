import CoreGraphics

extension CGRect {
    
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
        
        let enclosingRect = CGRect(origin: origin, size: newSize)
        debugPrint("enclosingRect = \(enclosingRect)")
        
        return enclosingRect
    }
    
    func cornersByApplyingTransform(transform: CGAffineTransform)
        -> (topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        
        let offsetX = size.width / 2
        let offsetY = size.height / 2
        
        // Трансформация, переносящая центр rect'а в начало координат
        let moveToZeroTransform = CGAffineTransformMakeTranslation(-offsetX, -offsetY)
        
        // Трансформация, которая будет преобразовывать расчитанные точки обратно в исходную систему координат
        let restorePositionTransform = CGAffineTransformMakeTranslation(offsetX, offsetY)
        
        var transform = CGAffineTransformConcat(moveToZeroTransform, transform)
        transform = CGAffineTransformConcat(transform, restorePositionTransform)
        
        let topLeft = CGPoint(x: left, y: top)
        let topRight = CGPoint(x: right, y: top)
        let bottomRight = CGPoint(x: right, y: bottom)
        let bottomLeft = CGPoint(x: left, y: bottom)
        
        return (
            topLeft: CGPointApplyAffineTransform(topLeft, transform),
            topRight: CGPointApplyAffineTransform(topRight, transform),
            bottomRight: CGPointApplyAffineTransform(bottomRight, transform),
            bottomLeft: CGPointApplyAffineTransform(bottomLeft, transform)
        )
    }
}