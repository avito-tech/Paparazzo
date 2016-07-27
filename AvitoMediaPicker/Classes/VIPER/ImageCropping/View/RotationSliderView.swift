import UIKit

final class RotationSliderView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    
    private let scrollView = UIScrollView()
    private let scaleView = SliderScaleView()
    private let thumbView = UIImageView()
    
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
        scrollView.bounces = false
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
        
        // Высчитываем этот inset, чтобы в случаях, когда слайдер находится в крайних положениях,
        // метки на шкале и указатель текущего значения совпадали
        let sideInset = (bounds.size.width - scaleView.divisionWidth) / 2 % (scaleView.divisionWidth + scaleView.divisionsSpacing)
        
        scaleView.contentInsets = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        scaleView.frame = CGRect(origin: .zero, size: scaleView.sizeThatFits(bounds.size))
        
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
        
        let value = max(minimumValue, min(maximumValue, value))
        let percentage = (value - minimumValue) / (maximumValue - minimumValue)
        
        scrollView.contentOffset = CGPoint(
            x: CGFloat(percentage) * (scrollView.contentSize.width - bounds.size.width),
            y: 0
        )
        
        debugPrint("value = \(value), contentOffset = \(scrollView.contentOffset)")
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.x
        let significantWidth = scrollView.contentSize.width - bounds.size.width
        let percentage = offset / significantWidth
        let value = minimumValue + (maximumValue - minimumValue) * Float(percentage)
        
        onSliderValueChange?(value)
        debugPrint("slider value = \(value)")
    }
    
    // Это отключает deceleration у scroll view
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
}

private final class SliderScaleView: UIView {
    
    var contentInsets = UIEdgeInsetsZero
    
    let divisionsSpacing = CGFloat(14)
    let divisionsCount = 51
    let divisionWidth = CGFloat(2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        var width = CGFloat(divisionsCount) * divisionWidth
        width += CGFloat(divisionsCount - 1) * divisionsSpacing
        width += contentInsets.left + contentInsets.right
        
        return CGSize(width: width, height: size.height)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        for i in 0 ..< divisionsCount {
            
            let rect = CGRect(
                x: bounds.left + contentInsets.left + CGFloat(i) * (divisionWidth + divisionsSpacing),
                y: bounds.top,
                width: divisionWidth,
                height: bounds.size.height
            )
            
            UIColor.RGBS(rgb: 217).setFill()    // TODO: transparency
            UIBezierPath(roundedRect: rect, cornerRadius: divisionWidth / 2).fill()
        }
    }
}
