final class ImageCroppingMask: UIView {
    
    private let topMask = UIView()
    private let bottomMask = UIView()
    private let leftMask = UIView()
    private let rightMask = UIView()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        let maskColor = UIColor.white.withAlphaComponent(0.9)
        
        topMask.backgroundColor = maskColor
        bottomMask.backgroundColor = maskColor
        leftMask.backgroundColor = maskColor
        rightMask.backgroundColor = maskColor
        
        addSubview(topMask)
        addSubview(bottomMask)
        addSubview(leftMask)
        addSubview(rightMask)
        
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CroppingMask
    
    func performLayoutUpdate(with cropSize: CGSize) {
        let horizontalMaskSize = CGSize(
            width: bounds.size.width,
            height: (bounds.size.height - cropSize.height) / 2
        )
        
        let verticalMaskSize = CGSize(
            width: (bounds.size.width - cropSize.width) / 2,
            height: bounds.size.height - horizontalMaskSize.height
        )
        
        topMask.frame = CGRect(
            origin: CGPoint(x: self.bounds.left, y: self.bounds.top),
            size: horizontalMaskSize
        )
        bottomMask.frame = CGRect(
            origin: CGPoint(x: self.bounds.left, y: self.bounds.bottom - horizontalMaskSize.height),
            size: horizontalMaskSize
        )
        leftMask.frame = CGRect(
            origin: CGPoint(x: self.bounds.left, y: self.topMask.bottom),
            size: verticalMaskSize
        )
        rightMask.frame = CGRect(
            origin: CGPoint(x: self.bounds.right - verticalMaskSize.width, y: self.topMask.bottom),
            size: verticalMaskSize
        )
    }
    
}
