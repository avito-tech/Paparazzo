import UIKit

final class PhotoRibbonDataSource: NSObject, UICollectionViewDataSource {
    
    let cellReuseIdentifier: String
    var onDataChanged: (() -> ())?
    
    private var photos = [PhotoPickerItem]()
    
    init(cellReuseIdentifier: String) {
        self.cellReuseIdentifier = cellReuseIdentifier
    }
    
    func photoAtIndexPath(indexPath: NSIndexPath) -> PhotoPickerItem {
        return photos[indexPath.row]
    }
    
    func addPhoto(photo: PhotoPickerItem) {
        
        photos.append(photo)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.onDataChanged?()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        let photo = photoAtIndexPath(indexPath)
        
        if let cell = cell as? PhotoRibbonCell {
            cell.image = photo.image
        }
        
        return cell
    }
}
