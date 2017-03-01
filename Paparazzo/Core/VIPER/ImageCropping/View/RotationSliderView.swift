import UIKit

final class RotationSliderView: UIView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    
    private let scrollView = UIScrollView()
    private let scaleView = SliderScaleView()
    private let thumbView = UIView()
    
    private let alphaMaskLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    private var minimumValue: Float = 0
    private var maximumValue: Float = 1
    private var currentValue: Float = 0
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentMode = .redraw
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        
        thumbView.backgroundColor = .black
        thumbView.layer.cornerRadius = scaleView.divisionWidth / 2
        
        alphaMaskLayer.startPoint = CGPoint(x: 0, y: 0)
        alphaMaskLayer.endPoint = CGPoint(x: 1, y: 0)
        alphaMaskLayer.locations = [0, 0.2, 0.8, 1]
        alphaMaskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        
        layer.mask = alphaMaskLayer
        
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
        let sideInset = ((bounds.size.width - scaleView.divisionWidth) / 2).truncatingRemainder(dividingBy: scaleView.divisionWidth + scaleView.divisionsSpacing)
        
        scaleView.contentInsets = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        scaleView.frame = CGRect(origin: .zero, size: scaleView.sizeThatFits(bounds.size))
        
        scrollView.frame = bounds
        scrollView.contentSize = scaleView.frame.size
        
        thumbView.size = CGSize(width: scaleView.divisionWidth, height: scaleView.height)
        thumbView.center = bounds.center
        
        alphaMaskLayer.frame = bounds
        
        adjustScrollViewOffset()
    }
    
    // MARK: - RotationSliderView
    
    var onSliderValueChange: ((Float) -> ())?
    
    func setMiminumValue(_ value: Float) {
        minimumValue = value
    }
    
    func setMaximumValue(_ value: Float) {
        maximumValue = value
    }
    
    func setValue(_ value: Float) {
        currentValue = max(minimumValue, min(maximumValue, value))
        adjustScrollViewOffset()
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.x
        let significantWidth = scrollView.contentSize.width - bounds.size.width
        let percentage = offset / significantWidth
        let value = minimumValue + (maximumValue - minimumValue) * Float(percentage)
        
        onSliderValueChange?(value)
    }
    
    // Это отключает deceleration у scroll view
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
    
    // MARK: - Private
    
    private func adjustScrollViewOffset() {
        
        let percentage = (currentValue - minimumValue) / (maximumValue - minimumValue)
        
        scrollView.contentOffset = CGPoint(
            x: CGFloat(percentage) * (scrollView.contentSize.width - bounds.size.width),
            y: 0
        )
    }
}

private final class SliderScaleView: UIView {
    
    var contentInsets = UIEdgeInsets.zero
    
    let divisionsSpacing = CGFloat(14)
    let divisionsCount = 51
    let divisionWidth = CGFloat(2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var width = CGFloat(divisionsCount) * divisionWidth
        width += CGFloat(divisionsCount - 1) * divisionsSpacing
        width += contentInsets.left + contentInsets.right
        
        return CGSize(width: width, height: size.height)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        for i in 0 ..< divisionsCount {
            
            let rect = CGRect(
                x: bounds.left + contentInsets.left + CGFloat(i) * (divisionWidth + divisionsSpacing),
                y: bounds.top,
                width: divisionWidth,
                height: bounds.size.height
            )
            
            UIColor.RGBS(rgb: 217).setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: divisionWidth / 2).fill()
        }
    }
}
