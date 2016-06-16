final class MediaRibbonCell: PhotoCollectionViewCell, Customizable {
    
    static let reuseIdentifier = "MediaRibbonCell"
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        image = item.image
    }
}