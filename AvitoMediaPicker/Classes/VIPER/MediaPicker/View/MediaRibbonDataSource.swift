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
    
    var onDataChanged: (() -> ())?
    
    var colors = MediaPickerColors()
    var images = MediaPickerImages()
    
    subscript(indexPath: NSIndexPath) -> MediaRibbonItem {
        if indexPath.item < mediaPickerItems.count {
            return .Photo(mediaPickerItems[indexPath.item])
        } else {
            return .Camera
        }
    }
    
    func addItem(item: MediaPickerItem) {
        mediaPickerItems.append(item)
        notifyAboutDataChange()
    }
    
    func setUpInCollectionView(collectionView: UICollectionView) {
        
        collectionView.registerClass(MediaRibbonCell.self, forCellWithReuseIdentifier: MediaRibbonCellReuseId)
        collectionView.registerClass(CameraCell.self, forCellWithReuseIdentifier: CameraCellReuseId)
        
        self.collectionView = collectionView
    }
    
    func indexPathForCameraCell() -> NSIndexPath {
        return NSIndexPath(forItem: mediaPickerItems.count, inSection: 0)
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
            cell.selectedBorderColor = colors.mediaRibbonSelectionColor
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
            cell.selectedBorderColor = colors.mediaRibbonSelectionColor
            cell.setCaptureSession(captureSession)
        }
    }
    
    private func notifyAboutDataChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.onDataChanged?()
        }
    }
}

enum MediaRibbonItem {
    case Photo(MediaPickerItem)
    case Camera
}