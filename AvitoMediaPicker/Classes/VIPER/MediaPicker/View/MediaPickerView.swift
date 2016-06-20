import UIKit
import AvitoDesignKit

final class MediaPickerView: UIView, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Subviews
    
    private var cameraView: UIView?
    private let photoView = UIImageView()
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    private let photoLibraryPeepholeView = UIImageView()
    private let closeButton = UIButton()
    private let continueButton = UIButton()
    private let flashView = UIView()
    
    private let mediaRibbonLayout = MediaRibbonLayout()
    private let mediaRibbonView: UICollectionView
    
    // MARK: - Constants
    
    private let cameraAspectRatio = CGFloat(4) / CGFloat(3)
    
    private let controlsCompactHeight = CGFloat(54) // (iPhone 4 height) - (iPhone 4 width) * 4 / 3 = 53,333...
    private let controlsExtendedHeight = CGFloat(83)
    
    private let mediaRibbonMinHeight = CGFloat(72)
    private let mediaRibbonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let mediaRibbonInteritemSpacing = CGFloat(7)
    
    // MARK: - Helpers
    
    private let mediaRibbonDataSource = CollectionViewDataSource<MediaRibbonCell>(
        cellReuseIdentifier: MediaRibbonCell.reuseIdentifier
    )
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        mediaRibbonLayout.scrollDirection = .Horizontal
        mediaRibbonLayout.sectionInset = mediaRibbonInsets
        mediaRibbonLayout.minimumLineSpacing = mediaRibbonInteritemSpacing
        
        mediaRibbonView = UICollectionView(frame: .zero, collectionViewLayout: mediaRibbonLayout)
        mediaRibbonView.backgroundColor = .whiteColor()
        mediaRibbonView.showsHorizontalScrollIndicator = false
        mediaRibbonView.showsVerticalScrollIndicator = false
        mediaRibbonView.registerClass(
            MediaRibbonCell.self,
            forCellWithReuseIdentifier: mediaRibbonDataSource.cellReuseIdentifier
        )
        
        super.init(frame: .zero)
        
        backgroundColor = .whiteColor()
        
        photoView.contentMode = .ScaleAspectFill
        photoView.clipsToBounds = true
        
        flashView.backgroundColor = .whiteColor()
        flashView.alpha = 0
        
        mediaRibbonDataSource.onDataChanged = { [weak self] in
            print("collectionViewDataSource.onDataChanged")
            self?.mediaRibbonView.reloadData()
        }
        
        mediaRibbonView.dataSource = mediaRibbonDataSource
        mediaRibbonView.delegate = self
        
        addSubview(photoView)
        addSubview(mediaRibbonView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(flashView)
        
        setMode(.Camera)
        setColors(MediaPickerColors())
        setImages(MediaPickerImages())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cameraFrame = CGRect(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: bounds.size.width * cameraAspectRatio
        )
        
        let photoPreviewSize = CGSize(width: cameraFrame.size.height, height: cameraFrame.size.height)
        let photoPreviewOrigin = CGPoint(x: bounds.centerX - photoPreviewSize.width / 2, y: bounds.top)
        let photoPreviewFrame = CGRect(origin: photoPreviewOrigin, size: photoPreviewSize)
        
        let freeSpaceUnderCamera = bounds.bottom - cameraFrame.bottom
        let canFitExtendedControls = (freeSpaceUnderCamera >= controlsExtendedHeight)
        let controlsHeight = canFitExtendedControls ? controlsExtendedHeight : controlsCompactHeight
        
        photoView.frame = photoPreviewFrame
        cameraView?.frame = cameraFrame
        
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: controlsHeight
        )
        
        photoControlsView.frame = cameraControlsView.frame

        let photoRibbonHeight = max(mediaRibbonMinHeight, cameraControlsView.top - photoView.bottom)

        mediaRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: photoRibbonHeight
        )

        mediaRibbonView.alpha = (cameraControlsView.top < cameraFrame.bottom) ? 0.25 /* TODO */ : 1

        flashView.frame = bounds
    }
    
    // MARK: - MediaPickerView
    
    var onShutterButtonTap: (() -> ())? {
        get { return cameraControlsView.onShutterButtonTap }
        set { cameraControlsView.onShutterButtonTap = newValue }
    }
    
    var onPhotoLibraryButtonTap: (() -> ())? {
        get { return cameraControlsView.onPhotoLibraryButtonTap }
        set { cameraControlsView.onPhotoLibraryButtonTap = newValue }
    }
    
    var onFlashToggle: (Bool -> ())? {
        get { return cameraControlsView.onFlashToggle }
        set { cameraControlsView.onFlashToggle = newValue }
    }
    
    var onCameraVisibilityChange: ((isCameraVisible: Bool) -> ())?
    var onPhotoSelect: (MediaPickerItem -> ())?
    
    var onRemoveButtonTap: (() -> ())? {
        get { return photoControlsView.onRemoveButtonTap }
        set { photoControlsView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return photoControlsView.onCropButtonTap }
        set { photoControlsView.onCropButtonTap = newValue }
    }
    
    var onReturnToCameraTap: (() -> ())? {
        get { return photoControlsView.onCameraButtonTap }
        set { photoControlsView.onCameraButtonTap = newValue }
    }
    
    func setMode(mode: MediaPickerViewMode) {
        
        switch mode {
        
        case .Camera:
            photoView.hidden = true
            photoView.image = nil
            
            cameraControlsView.hidden = false
            photoControlsView.hidden = true
            
            setCameraVisible(true)
        
        case .PhotoPreview(let photo):
            photoView.hidden = false
            photoView.setImage(photo.image)
            
            cameraControlsView.hidden = true
            photoControlsView.hidden = false
            
            setCameraVisible(false)
        }
    }
    
    func setLatestPhotoLibraryItemImage(image: ImageSource?) {
        cameraControlsView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(visible: Bool) {
        cameraControlsView.setFlashButtonVisible(visible)
    }
    
    func setFlashButtonOn(isOn: Bool) {
        cameraControlsView.setFlashButtonOn(isOn)
    }
    
    func animateFlash() {
        
        let fadeInOptions: UIViewAnimationOptions = [.CurveEaseIn]
        let fadeOutOptions: UIViewAnimationOptions = [.CurveEaseOut]
        
        UIView.animateWithDuration(0.1, delay: 0, options: fadeInOptions, animations: {
            self.flashView.alpha = 1
        }) { _ in
            UIView.animateWithDuration(0.2, delay: 0, options: fadeOutOptions, animations: {
                self.flashView.alpha = 0
                }, completion: nil)
        }
    }
    
    func addPhoto(photo: MediaPickerItem) {
        mediaRibbonDataSource.addItem(photo)
    }
    
    func removeSelectionInPhotoRibbon() {
        mediaRibbonView.indexPathsForSelectedItems()?.forEach { indexPath in
            mediaRibbonView.deselectItemAtIndexPath(indexPath, animated: false)
        }
    }
    
    func startSpinnerForNewPhoto() {
        print("startSpinnerForNewPhoto")
        // TODO
    }
    
    func stopSpinnerForNewPhoto() {
        print("stopSpinnerForNewPhoto")
        // TODO
    }

    func setControlsTransform(transform: CGAffineTransform) {
        
        photoView.transform = transform
        
        cameraControlsView.setControlsTransform(transform)
        photoControlsView.setControlsTransform(transform)
        
        mediaRibbonLayout.itemsTransform = transform
        mediaRibbonLayout.invalidateLayout()
    }
    
    func setCameraView(view: UIView) {
        cameraView?.removeFromSuperview()
        cameraView = view
        addSubview(view)
    }
    
    func setColors(colors: MediaPickerColors) {
        cameraControlsView.setColors(colors)
        photoControlsView.setColors(colors)
    }
    
    func setImages(images: MediaPickerImages) {
        cameraControlsView.setImages(images)
        photoControlsView.setImages(images)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = mediaRibbonDataSource.item(atIndexPath: indexPath)
        onPhotoSelect?(photo)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = mediaRibbonView.height - mediaRibbonInsets.top - mediaRibbonInsets.bottom
        return CGSize(width: height, height: height)
    }
    
    // MARK: - Private
    
    private func setCameraVisible(visible: Bool) {
        cameraView?.hidden = !visible
        onCameraVisibilityChange?(isCameraVisible: visible)
    }
}