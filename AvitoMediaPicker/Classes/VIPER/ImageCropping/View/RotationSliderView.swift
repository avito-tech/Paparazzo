import UIKit

final class RotationSliderView: UIView {
    
    // MARK: - Subviews
    
    private let slider = UISlider()
    
    // MARK: - Constants
    
    private let divisionsCount = 17
    private let divisionWidth = CGFloat(2)
    
    // Зависит от размеров непрозрачной части thumb'а слайдера
    private let scaleInsets = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clearColor()
        contentMode = .Redraw
        
        setUpSlider()
        
        addSubview(slider)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let scaleRect = bounds.shrinked(scaleInsets)
        let divisionsSpacing = (scaleRect.size.width - CGFloat(divisionsCount) * divisionWidth) / (CGFloat(divisionsCount) - 1)
        
        for i in 0 ..< divisionsCount {
            
            let rect = CGRect(
                x: scaleRect.left + CGFloat(i) * (divisionWidth + divisionsSpacing),
                y: scaleRect.top,
                width: divisionWidth,
                height: scaleRect.size.height
            )
            
            UIColor.RGBS(rgb: 217).setFill()    // TODO: transparency
            UIBezierPath(roundedRect: rect, cornerRadius: divisionWidth / 2).fill()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        slider.frame = bounds.shrinked(scaleInsets)
    }
    
    // MARK: - RotationSliderView
    
    var onSliderValueChange: (Float -> ())?
    
    func setMiminumValue(value: Float) {
        slider.minimumValue = value
    }
    
    func setMaximumValue(value: Float) {
        slider.maximumValue = value
    }
    
    func setValue(value: Float) {
        slider.value = value
    }
    
    // MARK: - Private
    
    private func setUpSlider() {
        
        let thumbImage = UIImage(
            named: "rotation-slider-thumb",
            inBundle: NSBundle(forClass: self.dynamicType),
            compatibleWithTraitCollection: nil
        )
        
        slider.setMinimumTrackImage(UIImage(), forState: .Normal)
        slider.setMaximumTrackImage(UIImage(), forState: .Normal)
        slider.setThumbImage(thumbImage, forState: .Normal)
        slider.addTarget(
            self,
            action: #selector(onRotationSliderValueChange(_:)),
            forControlEvents: .ValueChanged
        )
    }
    
    @objc private func onRotationSliderValueChange(sender: UISlider) {
        onSliderValueChange?(sender.value)
    }
}
