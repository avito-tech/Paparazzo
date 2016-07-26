import UIKit

final class RotationSliderView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    
    private let scrollView = UIScrollView()
    private let scaleView = SliderScaleView()
    private let thumbView = UIImageView()
    
    // MARK: - Constants
    
    private let divisionsCount = 17
    
    // MARK: - Properties
    
    private var minimumValue: Float = 0
    private var maximumValue: Float = 1
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clearColor()
        contentMode = .Redraw
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.delegate = self
        
        thumbView.image = UIImage(
            named: "rotation-slider-thumb",
            inBundle: NSBundle(forClass: self.dynamicType),
            compatibleWithTraitCollection: nil
        )
        
        scrollView.addSubview(scaleView)
        
        addSubview(scrollView)
        addSubview(thumbView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scaleView.frame = CGRect(x: 0, y: 0, width: 1000, height: bounds.size.height)
        
        scrollView.frame = bounds
        scrollView.contentSize = scaleView.frame.size
        
        thumbView.sizeToFit()
        thumbView.center = bounds.center
    }
    
    // MARK: - RotationSliderView
    
    var onSliderValueChange: (Float -> ())?
    
    func setMiminumValue(value: Float) {
        minimumValue = value
    }
    
    func setMaximumValue(value: Float) {
        maximumValue = value
    }
    
    func setValue(value: Float) {
        scrollView.contentOffset = .zero    // TODO
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        onSliderValueChange?(0.5)   // TODO
    }
}

private final class SliderScaleView: UIView {
    
    let divisionsSpacing = CGFloat(14)
    let divisionWidth = CGFloat(2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let divisionsCount = Int(floor(bounds.size.width / divisionsSpacing))
        
        for i in 0 ..< divisionsCount {
            
            let rect = CGRect(
                x: bounds.left + CGFloat(i) * (divisionWidth + divisionsSpacing),
                y: bounds.top,
                width: divisionWidth,
                height: bounds.size.height
            )
            
            UIColor.RGBS(rgb: 217).setFill()    // TODO: transparency
            UIBezierPath(roundedRect: rect, cornerRadius: divisionWidth / 2).fill()
        }
    }
}
