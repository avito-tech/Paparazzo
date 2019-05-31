import ImageSource
import UIKit

final class PhotoLibraryItemCell: PhotoCollectionViewCell, Customizable {
    
    private let cloudIconView = UIImageView()
    
    // MARK: - UICollectionViewCell
    
    override var backgroundColor: UIColor? {
        get { return backgroundView?.backgroundColor }
        set { backgroundView?.backgroundColor = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = UIView()
        let onePixel = 1.0 / UIScreen.main.nativeScale
        
        self.backgroundView = backgroundView
        
        selectedBorderThickness = 5
        
        imageView.isAccessibilityElement = true
        imageViewInsets = UIEdgeInsets(top: onePixel, left: onePixel, bottom: onePixel, right: onePixel)
        
        setUpRoundedCorners(for: self)
        setUpRoundedCorners(for: backgroundView)
        setUpRoundedCorners(for: imageView)
        
        contentView.insertSubview(cloudIconView, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let onePixel = CGFloat(1) / UIScreen.main.nativeScale
        let backgroundInsets = UIEdgeInsets(top: onePixel, left: onePixel, bottom: onePixel, right: onePixel)
        
        backgroundView?.frame = imageView.frame.inset(by: backgroundInsets)
        
        cloudIconView.sizeToFit()
        cloudIconView.right = contentView.bounds.right
        cloudIconView.bottom = contentView.bounds.bottom
    }
    
    override func didRequestImage(requestId imageRequestId: ImageRequestId) {
        self.imageRequestId = imageRequestId
    }
    
    override func imageRequestResultReceived(_ result: ImageRequestResult<UIImage>) {
        if result.requestId == self.imageRequestId {
            onImageSetFromSource?()
        }
    }
    
    // MARK: - PhotoLibraryItemCell
    
    func setCloudIcon(_ icon: UIImage?) {
        cloudIconView.image = icon
        setNeedsLayout()
    }
    
    func setAccessibilityId(index: Int) {
        accessibilityIdentifier = AccessibilityId.mediaItemThumbnailCell.rawValue + "-\(index)"
    }
    
    // MARK: - Customizable
    
    var onImageSetFromSource: (() -> ())?
    
    func customizeWithItem(_ item: PhotoLibraryItemCellData) {
        imageSource = item.image
        isSelected = item.selected
    }
    
    // MARK: - Private
    
    private var imageRequestId: ImageRequestId?
    
    private func setUpRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.nativeScale
    }
}
