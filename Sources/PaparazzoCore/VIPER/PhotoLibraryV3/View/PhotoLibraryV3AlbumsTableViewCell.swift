import ImageSource
import UIKit

// TODO: (ayutkin) make base table view cell for image source in ImageSource/UIKit
// TODO: (ayutkin) add placeholder image for empty albums
final class PhotoLibraryV3AlbumsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    private var coverImage: ImageSource? {
        didSet {
            updateImage()
        }
    }
    
    // MARK: UI elements
    
    private lazy var label = UILabel()
    
    private lazy var coverImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        image.layer.shouldRasterize = true
        image.layer.rasterizationScale = UIScreen.main.nativeScale
        image.accessibilityIdentifier = AccessibilityId.albumsCoverImageView.rawValue
        return image
    }()
    
    // MARK: Spec
    
    private enum Spec {
        static let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let imageSize = CGSize(width: 52, height: 52)
        static let imageToTitleSpacing: CGFloat = 12
    }
    
    // MARK: Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .white

        contentView.addSubview(coverImageView)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coverImageView.frame = CGRect(
            x: contentView.bounds.left + Spec.insets.left,
            y: contentView.bounds.top + floor((bounds.height - Spec.imageSize.height) / 2),
            width: Spec.imageSize.width,
            height: Spec.imageSize.height
        )
        
        updateImage()
        
        let labelLeft = coverImageView.right + Spec.imageToTitleSpacing
        let labelMaxWidth = (bounds.right - Spec.insets.right) - labelLeft
        
        label.resizeToFitWidth(labelMaxWidth)
        label.left = labelLeft
        label.centerY = bounds.centerY
    }
    
    // MARK: Public methods
    
    func setCellData(_ cellData: PhotoLibraryAlbumCellData) {
        label.text = cellData.title
        coverImage = cellData.coverImage
    }
    
    func setLabelFont(_ font: UIFont) {
        label.font = font
    }
    
    func setDefaultLabelColor(_ color: UIColor) {
        label.textColor = color
    }
    
    func setImageCornerRadius(_ radius: CGFloat) {
        coverImageView.layer.cornerRadius = radius
    }
}

// MARK: - Private methods

private extension PhotoLibraryV3AlbumsTableViewCell {
    func updateImage() {
        coverImageView.setImage(fromSource: coverImage)
    }
}
