import UIKit

final class PhotoLibraryItemCell: PhotoCollectionViewCell, Customizable {
    
    private let cloudIconView = UIImageView()
    
    // MARK: - UICollectionViewCell
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.insertSubview(cloudIconView, atIndex: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cloudIconView.sizeToFit()
        cloudIconView.right = bounds.right
        cloudIconView.bottom = bounds.bottom
    }
    
    override func didRequestImage(imageRequestId: ImageRequestId) {
        self.imageRequestId = imageRequestId
    }
    
    override func imageRequestResultReceived(result: ImageRequestResult<UIImage>) {
        if result.requestId == self.imageRequestId {
            onImageSetFromSource?()
        }
    }
    
    // MARK: - PhotoLibraryItemCell
    
    func setCloudIcon(icon: UIImage?) {
        cloudIconView.image = icon
        setNeedsLayout()
    }
    
    // MARK: - Customizable
    
    var onImageSetFromSource: (() -> ())?
    
    func customizeWithItem(item: PhotoLibraryItemCellData) {
        imageSource = item.image
        selected = item.selected
    }
    
    // MARK: - Private
    
    private var imageRequestId: ImageRequestId?
}
