final class MediaItemThumbnailCell: PhotoCollectionViewCell, Customizable {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 6
        layer.masksToBounds = true
        
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        
        imageViewInsets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
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
