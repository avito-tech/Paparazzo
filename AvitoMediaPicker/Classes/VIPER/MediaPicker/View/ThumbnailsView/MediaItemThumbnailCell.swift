final class MediaItemThumbnailCell: PhotoCollectionViewCell, Customizable {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selected = false
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        imageSource = item.image
    }
}