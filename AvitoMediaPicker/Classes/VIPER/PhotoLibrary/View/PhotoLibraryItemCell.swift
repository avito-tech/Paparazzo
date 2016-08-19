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
    
    override func configureImageRequest(inout options: ImageRequestOptions) {
        super.configureImageRequest(&options)
        
        options.onDownloadStart = { [onLoadingStart, superOptions = options] in
            superOptions.onDownloadStart?()
            onLoadingStart?()
        }
        
        options.onDownloadFinish = { [onLoadingFinish, superOptions = options] in
            superOptions.onDownloadFinish?()
            onLoadingFinish?()
        }
    }
    
    // MARK: - PhotoLibraryItemCell
    
    func setCloudIcon(icon: UIImage?) {
        cloudIconView.image = icon
        setNeedsLayout()
    }
    
    // MARK: - Customizable
    
    var onLoadingStart: (() -> ())?
    var onLoadingFinish: (() -> ())?
    
    func customizeWithItem(item: PhotoLibraryItemCellData) {
        image = item.image
        selected = item.selected
    }
}
