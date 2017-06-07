import UIKit

final class MaskCropperOverlayView: UIView {
    
    private let croppingOverlayProvider: CroppingOverlayProvider
    
    // MARK: - Init
    
    init(croppingOverlayProvider: CroppingOverlayProvider) {
        
        self.croppingOverlayProvider = croppingOverlayProvider
        
        super.init(frame: .zero)
        
        isOpaque = false
    }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.withAlphaComponent(0.6).cgColor)
        context?.fill(rect)
        context?.saveGState()
        context?.setBlendMode(.clear)
        
        let rectToCrop = croppingOverlayProvider.calculateRectToCrop(in: bounds)
        if rect.intersects(rectToCrop) {
            context?.setFillColor(UIColor.clear.cgColor)
            
            context?.addPath(croppingOverlayProvider.croppingPath(in: rectToCrop))
            context?.drawPath(using: .fill)
        }
        
        context?.restoreGState()
    }
    
    // MARK: - Unused
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
