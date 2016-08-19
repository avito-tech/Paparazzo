import UIKit

final class PhotoLibraryItemCell: PhotoCollectionViewCell, Customizable {
    
    private let cloudIconView = UIImageView()
    private let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
    
    // MARK: - UICollectionViewCell
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressIndicator.hidesWhenStopped = true
        
        contentView.insertSubview(cloudIconView, atIndex: 0)
        contentView.addSubview(progressIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cloudIconView.sizeToFit()
        cloudIconView.right = bounds.right
        cloudIconView.bottom = bounds.bottom
        
        progressIndicator.center = bounds.center
    }
    
    override func configureImageRequest(inout options: ImageRequestOptions) {
        super.configureImageRequest(&options)
        
        let superOptions = options
        
        options.onDownloadProgressChange = { [weak self] progress in
            superOptions.onDownloadProgressChange?(downloadProgress: progress)
            self?.onLoadingProgress?(progress)
        }
    }
    
    // MARK: - PhotoLibraryItemCell
    
    func setCloudIcon(icon: UIImage?) {
        cloudIconView.image = icon
        setNeedsLayout()
    }
    
    // MARK: - Customizable
    
    var onLoadingProgress: (Float -> ())?
    
    func customizeWithItem(item: PhotoLibraryItemCellData) {
        image = item.image
        selected = item.selected
    }
}
