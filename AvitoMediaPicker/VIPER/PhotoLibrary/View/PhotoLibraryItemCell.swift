final class PhotoLibraryItemCell: PhotoCollectionViewCell, Customizable {
    
    static let reuseIdentifier = "PhotoLibraryItemCell"
    
    // MARK: - Customizable
    
    func customizeWithItem(item: PhotoLibraryItem) {
        image = item.image
    }
}
