final class MediaRibbonCell: PhotoCollectionViewCell, Customizable {
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        image = item.image
    }
}