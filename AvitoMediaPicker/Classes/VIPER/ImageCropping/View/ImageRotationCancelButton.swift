import Foundation

final class ImageRotationCancelButton: UIButton {
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = super.imageRectForContentRect(contentRect)
        rect.left = super.titleRectForContentRect(contentRect).left
        return rect
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = super.titleRectForContentRect(contentRect)
        rect.right = super.imageRectForContentRect(contentRect).right
        return rect
    }
}
