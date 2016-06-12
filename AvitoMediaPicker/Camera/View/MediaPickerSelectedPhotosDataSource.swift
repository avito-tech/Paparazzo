import UIKit

final class MediaPickerSelectedPhotosDataSource: NSObject, UICollectionViewDataSource {
    
    let cellReuseIdentifier: String
    var onDataChanged: (() -> ())?
    
    private var photos = [CameraPhoto]()
    
    init(cellReuseIdentifier: String) {
        self.cellReuseIdentifier = cellReuseIdentifier
    }
    
    func photoAtIndexPath(indexPath: NSIndexPath) -> CameraPhoto {
        return photos[indexPath.row]
    }
    
    func addPhoto(photo: CameraPhoto) {
        
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
        
        if let cell = cell as? MediaPickerCollectionViewCell, photoPath = photo.thumbnailUrl.path {
            cell.imageView.image = UIImage(contentsOfFile: photoPath)
        }
        
        return cell
    }
}
