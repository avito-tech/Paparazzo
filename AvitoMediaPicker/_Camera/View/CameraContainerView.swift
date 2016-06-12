import UIKit

final class CameraContainerView: UIView {
    
    // MARK: - Subviews
    
    private let outputContainer = ContainerView()
    private let panelContainer = ContainerView()
    private let takePhotoButton = UIButton()
    
    var onTakePhotoButtonTap: (() -> ())?
    
    // MARK: - Sizes
    
    private let panelHeight = CGFloat(194)
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        outputContainer.backgroundColor = .greenColor()
        panelContainer.backgroundColor = .yellowColor()
        
        takePhotoButton.setTitle("Take photo", forState: .Normal)
        takePhotoButton.addTarget(
            self,
            action: #selector(CameraContainerView.onTakePhotoButtonTap(_:)),
            forControlEvents: .TouchUpInside)
        
        panelContainer.addSubview(takePhotoButton)
        
        addSubview(outputContainer)
        addSubview(panelContainer)
    }
    
    @objc private func onTakePhotoButtonTap(button: UIButton) {
        onTakePhotoButtonTap?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        outputContainer.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: bounds.width,
            height: bounds.height - panelHeight
        )
        
        panelContainer.frame = CGRect(
            x: bounds.minX,
            y: outputContainer.frame.maxY,
            width: bounds.width,
            height: panelHeight
        )
        
        takePhotoButton.center = CGPoint(x: panelContainer.bounds.midX, y: panelContainer.bounds.midY)
    }
    
    // MARK: - ContainerView
    
    func setOutputView(view: UIView) {
        outputContainer.contentView = view
    }
    
    func setPanelView(view: UIView) {
        panelContainer.contentView = view
    }
}

final class ContainerView: UIView {
    
    var contentView: UIView? {
        get { return subviews.first }
        set {
            subviews.forEach { $0.removeFromSuperview() }
            
            if let newValue = newValue {
                addSubview(newValue)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView?.frame = bounds
    }
}