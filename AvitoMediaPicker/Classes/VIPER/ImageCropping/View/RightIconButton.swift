import Foundation

final class RightIconButton: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.imageRect(forContentRect: contentRect)
        rect.right = contentRect.right
        return rect
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var rect = super.titleRect(forContentRect: contentRect)
        rect.left = contentRect.left
        return rect
    }
}
