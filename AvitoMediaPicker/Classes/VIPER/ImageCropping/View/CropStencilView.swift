import Foundation

final class CropStencilView: UIView {
    
    // MARK: - Subviews
    
    private let topCurtain = UIView()
    private let bottomCurtain = UIView()
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCurtain(topCurtain)
        setUpCurtain(bottomCurtain)
        
        addSubview(topCurtain)
        addSubview(bottomCurtain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let nonDimmedHeight = bounds.size.width / aspectRatio
        
        let nonDimmedArea = CGRect(
            x: bounds.left,
            y: bounds.centerY - nonDimmedHeight / 2,
            width: bounds.size.width,
            height: nonDimmedHeight
        )
        
        topCurtain.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            bottom: nonDimmedArea.top
        )
        
        bottomCurtain.layout(
            left: bounds.left,
            right: bounds.right,
            top: nonDimmedArea.bottom,
            bottom: bounds.bottom
        )
    }
    
    // MARK: - CropStencilView
    
    var aspectRatio = CGFloat(4.0 / 3.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Private
    
    private func setUpCurtain(view: UIView) {
        view.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
    }
}
