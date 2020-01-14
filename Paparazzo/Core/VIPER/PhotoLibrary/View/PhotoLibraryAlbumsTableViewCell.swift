import ImageSource
import UIKit

// TODO: (ayutkin) make base table view cell for image source in ImageSource/UIKit
// TODO: (ayutkin) add placeholder image for empty albums
final class PhotoLibraryAlbumsTableViewCell: UITableViewCell {
    
    // MARK: - Specs
    private let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    private let imageSize = CGSize(width: 44, height: 44)
    private let imageToTitleSpacing: CGFloat = 16
    private var defaultLabelColor = UIColor.RGB(red: 51, green: 51, blue: 51)
    private var selectedLabelColor = UIColor.RGB(red: 0, green: 170, blue: 255)
    
    // MARK: - Subviews
    private let label = UILabel()
    private let coverImageView = UIImageView()
    
    // MARK: - Data
    private var coverImage: ImageSource? {
        didSet {
            updateImage()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedLabelColor : defaultLabelColor
        }
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .white
        
        coverImageView.backgroundColor = .lightGray
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = 6
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.shouldRasterize = true
        coverImageView.layer.rasterizationScale = UIScreen.main.nativeScale
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PhotoLibraryAlbumsTableViewCell
    func setCellData(_ cellData: PhotoLibraryAlbumCellData) {
        label.text = cellData.title
        coverImage = cellData.coverImage
    }
    
    func setLabelFont(_ font: UIFont) {
        label.font = font
    }
    
    func setDefaultLabelColor(_ color: UIColor) {
        defaultLabelColor = color
    }
    
    func setSelectedLabelColor(_ color: UIColor) {
        selectedLabelColor = color
    }
    
    // MARK: - UITableViewCell
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coverImageView.frame = CGRect(
            x: contentView.bounds.left + insets.left,
            y: contentView.bounds.top + floor((bounds.height - imageSize.height) / 2),
            width: imageSize.width,
            height: imageSize.height
        )
        
        updateImage()
        
        let labelLeft = coverImageView.right + imageToTitleSpacing
        let labelMaxWidth = (bounds.right - insets.right) - labelLeft
        
        label.resizeToFitWidth(labelMaxWidth)
        label.left = labelLeft
        label.centerY = bounds.centerY
    }
    
    // MARK: - Private
    private func updateImage() {
        coverImageView.setImage(fromSource: coverImage)
    }
}
