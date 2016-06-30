import UIKit

final class PhotoPreviewCell: PhotoCollectionViewCell {
    
    override class var imageViewContentMode: UIViewContentMode {
        return .ScaleAspectFit
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        image = item.image
    }
}
