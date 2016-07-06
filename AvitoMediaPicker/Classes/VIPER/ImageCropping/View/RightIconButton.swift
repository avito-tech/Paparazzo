import Foundation

final class RightIconButton: UIButton {
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = super.imageRectForContentRect(contentRect)
        rect.right = super.titleRectForContentRect(contentRect).right
        return rect
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = super.titleRectForContentRect(contentRect)
        rect.left = super.imageRectForContentRect(contentRect).left
        return rect
    }
}
