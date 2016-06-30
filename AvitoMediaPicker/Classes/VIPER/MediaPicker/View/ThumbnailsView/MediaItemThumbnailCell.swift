final class MediaItemThumbnailCell: PhotoCollectionViewCell, Customizable {
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        image = item.image
    }
}