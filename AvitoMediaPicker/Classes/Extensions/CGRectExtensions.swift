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
    func scaled(_ scale: CGFloat) -> CGSize {
        return CGSize(width: width * scale, height: height * scale)
    }
}
