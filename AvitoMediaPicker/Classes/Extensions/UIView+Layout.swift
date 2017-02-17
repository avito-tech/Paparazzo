import UIKit

extension UIView {
    // MARK: - Alignment: single axis
    final func layout(left: CGFloat, right: CGFloat) {
        self.left = left
        self.width = right - left
    }
    
    final func layout(top: CGFloat, bottom: CGFloat) {
        self.top = top
        self.height = bottom - top
    }
    
    // MARK: - Alignment: all axis
    final func layout(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        layout(left: left, right: right)
        layout(top: top, bottom: bottom)
    }
    
    final func layout(left: CGFloat, right: CGFloat, top: CGFloat, height: CGFloat) {
        layout(left: left, right: right)
        self.top = top
        self.height = height
    }
    
    final func layout(left: CGFloat, right: CGFloat, bottom: CGFloat, height: CGFloat) {
        layout(left: left, right: right)
        self.height = height
        self.bottom = bottom
    }
    
    final func layout(top: CGFloat, bottom: CGFloat, left: CGFloat, width: CGFloat) {
        layout(top: top, bottom: bottom)
        self.left = left
        self.width = width
    }
    
    final func layout(top: CGFloat, bottom: CGFloat, right: CGFloat, width: CGFloat) {
        layout(top: top, bottom: bottom)
        self.width = width
        self.right = right
    }
    
    final func layout(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) {
        layout(top: top, bottom: bottom)
        self.left = left
        self.right = right
    }
    
    final func layout(right: CGFloat, bottom: CGFloat) {
        self.right = right
        self.bottom = bottom
    }
    
    final func layout(right: CGFloat, top: CGFloat) {
        self.right = right
        self.top = top
    }
    
    final func layout(left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) {
        self.left = left
        self.top = top
        self.width = width
        self.height = height
    }
    
    // MARK: - Alignment with autoresize: single axis
    
    // Y coordinate is not specified
    final func layout(left: CGFloat, right: CGFloat, fitHeight: CGFloat) {
        self.left = left
        self.width = right - left
        self.height = min(fitHeight, sizeThatFits(CGSize(width: width, height: fitHeight)).height)
    }
    
    // X coordinate is not specified
    final func layout(top: CGFloat, bottom: CGFloat, fitWidth: CGFloat) {
        self.top = top
        self.height = bottom - top
        self.width = min(fitWidth, sizeThatFits(CGSize(width: fitWidth, height: height)).width)
    }

    // MARK: - Alignment with autoresize: all axis
    
    // Fixed width, flexible height:
    
    final func layout(left: CGFloat, right: CGFloat, top: CGFloat, fitHeight: CGFloat) {
        layout(left: left, right: right, fitHeight: fitHeight)
        self.top = top
    }
    
    final func layout(left: CGFloat, right: CGFloat, top: CGFloat, fitBottom: CGFloat) {
        layout(left: left, right: right, top: top, fitHeight: fitBottom - top)
    }
    
    final func layout(left: CGFloat, right: CGFloat, bottom: CGFloat, fitHeight: CGFloat) {
        layout(left: left, right: right, fitHeight: fitHeight)
        self.bottom = bottom
    }
    
    final func layout(left: CGFloat, right: CGFloat, bottom: CGFloat, fitTop: CGFloat) {
        layout(left: left, right: right, bottom: bottom, fitHeight: bottom - fitTop)
    }
    
    // Fixed height, flexible width:
    
    final func layout(top: CGFloat, bottom: CGFloat, left: CGFloat, fitWidth: CGFloat) {
        layout(top: top, bottom: bottom, fitWidth: fitWidth)
        self.left = left
    }
    
    final func layout(top: CGFloat, bottom: CGFloat, left: CGFloat, fitRight: CGFloat) {
        layout(top: top, bottom: bottom, left: left, fitWidth: fitRight - left)
    }
    
    final func layout(top: CGFloat, bottom: CGFloat, right: CGFloat, fitWidth: CGFloat) {
        layout(top: top, bottom: bottom, fitWidth: fitWidth)
        self.right = right
    }
    
    final func layout(top: CGFloat, bottom: CGFloat, right: CGFloat, fitLeft: CGFloat) {
        layout(top: top, bottom: bottom, right: right, fitWidth: right - fitLeft)
    }
    
    final func layout(left: CGFloat, top: CGFloat, height: CGFloat, fitRight: CGFloat) {
        layout(top: top, bottom: top + height, left: left, fitRight: fitRight)
    }
    
    // Flexible width, flexible height
    
    final func layout(left: CGFloat, top: CGFloat, fitRight: CGFloat, fitBottom: CGFloat) {
        resizeToFitSize(CGSize(width: fitRight - left, height: fitBottom - top))
        self.left = left
        self.top = top
    }
    
    final func layout(left: CGFloat, bottom: CGFloat, fitWidth: CGFloat, fitHeight: CGFloat) {
        resizeToFitSize(CGSize(width: fitWidth, height: fitHeight))
        self.left = left
        self.bottom = bottom
    }
    
    final func layout(right: CGFloat, top: CGFloat, fitWidth: CGFloat, fitHeight: CGFloat) {
        resizeToFitSize(CGSize(width: fitWidth, height: fitHeight))
        self.top = top
        self.right = right
    }
    
    final func layout(right: CGFloat, bottom: CGFloat, fitWidth: CGFloat, fitHeight: CGFloat) {
        resizeToFitSize(CGSize(width: fitWidth, height: fitHeight))
        self.bottom = bottom
        self.right = right
    }
}

    
