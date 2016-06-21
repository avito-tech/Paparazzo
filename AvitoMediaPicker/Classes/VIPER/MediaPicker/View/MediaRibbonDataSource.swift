import UIKit
import AVFoundation

final class MediaRibbonDataSource: NSObject, UICollectionViewDataSource {
    
    private var mediaPickerItems = [MediaPickerItem]()
    private var collectionView: UICollectionView?
    
    private let MediaRibbonCellReuseId = "MediaRibbonCell"
    private let CameraCellReuseId = "CameraCell"
    
    // MARK: - MediaRibbonDataSource
    
    var captureSession: AVCaptureSession? {
        didSet {
            updateCameraCell()
        }
    }
    
    var theme: MediaPickerRootModuleUITheme?

    subscript(indexPath: NSIndexPath) -> MediaRibbonItem {
        if indexPath.item < mediaPickerItems.count {
            return .Photo(mediaPickerItems[indexPath.item])
        } else {
            return .Camera
        }
    }
    
    func addItem(item: MediaPickerItem) {
        collectionView?.performBatchUpdates({
            let indexPath = NSIndexPath(forItem: self.mediaPickerItems.count, inSection: 0)
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
            self.mediaPickerItems.append(item)
        }, completion: nil)
    }
    
    func removeItem(item: MediaPickerItem) {
        if let index = mediaPickerItems.indexOf(item) {
            collectionView?.performBatchUpdates({
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                self.mediaPickerItems.removeAtIndex(index)
            }, completion: nil)
        }
    }
    
    func setUpInCollectionView(collectionView: UICollectionView) {
        
        collectionView.registerClass(MediaRibbonCell.self, forCellWithReuseIdentifier: MediaRibbonCellReuseId)
        collectionView.registerClass(CameraCell.self, forCellWithReuseIdentifier: CameraCellReuseId)
        
        self.collectionView = collectionView
    }
    
    func indexPathForItem(item: MediaPickerItem) -> NSIndexPath? {
        return mediaPickerItems.indexOf(item).flatMap { NSIndexPath(forItem: $0, inSection: 0) }
    }
    
    func indexPathForCameraCell() -> NSIndexPath {
        return NSIndexPath(forItem: mediaPickerItems.count, inSection: 0)
    }
    
    func cameraCell() -> CameraCell? {
        return collectionView?.cellForItemAtIndexPath(indexPathForCameraCell()) as? CameraCell
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaPickerItems.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < mediaPickerItems.count {
            return itemCell(forIndexPath: indexPath, inCollectionView: collectionView)
        } else {
            return cameraCell(forIndexPath: indexPath, inCollectionView: collectionView)
        }
    }
    
    // MARK: - Private
    
    private func itemCell(forIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MediaRibbonCellReuseId, forIndexPath: indexPath)
        let item = mediaPickerItems[indexPath.item]
        
        if let cell = cell as? MediaRibbonCell {
            cell.selectedBorderColor = theme?.mediaRibbonSelectionColor
            cell.customizeWithItem(item)
        }
        
        return cell
    }
    
    private func cameraCell(forIndexPath indexPath: NSIndexPath, inCollectionView collectionView: UICollectionView) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CameraCellReuseId, forIndexPath: indexPath)
        setUpCameraCell(cell)
        return cell
    }
    
    private func updateCameraCell() {
        if let cell = collectionView?.cellForItemAtIndexPath(indexPathForCameraCell()) {
            setUpCameraCell(cell)
        }
    }
    
    private func setUpCameraCell(cell: UICollectionViewCell) {
        if let cell = cell as? CameraCell, captureSession = captureSession {
            cell.selectedBorderColor = theme?.mediaRibbonSelectionColor
            cell.setCameraIcon(theme?.returnToCameraIcon)
            cell.setCaptureSession(captureSession)
        }
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}