final class MediaItemThumbnailCell: PhotoCollectionViewCell, Customizable {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(_ item: MediaPickerItem) {
        imageSource = item.image
    }
}
