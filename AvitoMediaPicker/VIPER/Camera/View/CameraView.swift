import UIKit
import AVFoundation
import AvitoDesignKit

final class CameraView: UIView, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Subviews
    
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private let photoView = UIImageView()
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    private let photoLibraryPeepholeView = UIImageView()
    private let closeButton = UIButton()
    private let continueButton = UIButton()
    private let flashView = UIView()
    
    private let photoRibbonLayout = PhotoRibbonLayout()
    private let photoRibbonView: UICollectionView
    
    // MARK: - Constants
    
    private let cameraAspectRatio = CGFloat(4) / CGFloat(3)
    
    private let controlsCompactHeight = CGFloat(54) // (iPhone 4 height) - (iPhone 4 width) * 4 / 3 = 53,333...
    private let controlsExtendedHeight = CGFloat(83)
    
    private let photoRibbonMinHeight = CGFloat(72)
    private let photoRibbonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let photoRibbonInteritemSpacing = CGFloat(7)
    
    // MARK: - Helpers
    
    private let photosRibbonDataSource = MediaPickerSelectedPhotosDataSource(
        cellReuseIdentifier: MediaPickerCollectionViewCell.reuseIdentifier
    )
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        photoRibbonLayout.scrollDirection = .Horizontal
        photoRibbonLayout.sectionInset = photoRibbonInsets
        photoRibbonLayout.minimumLineSpacing = photoRibbonInteritemSpacing
        
        photoRibbonView = UICollectionView(frame: .zero, collectionViewLayout: photoRibbonLayout)
        photoRibbonView.backgroundColor = .whiteColor()
        photoRibbonView.showsHorizontalScrollIndicator = false
        photoRibbonView.showsVerticalScrollIndicator = false
        photoRibbonView.registerClass(
            MediaPickerCollectionViewCell.self,
            forCellWithReuseIdentifier: MediaPickerCollectionViewCell.reuseIdentifier
        )
        
        super.init(frame: .zero)
        
        backgroundColor = .whiteColor()
        
        photoView.contentMode = .ScaleAspectFill
        photoView.clipsToBounds = true
        
        flashView.backgroundColor = .whiteColor()
        flashView.alpha = 0
        
        photosRibbonDataSource.onDataChanged = { [weak self] in
            print("collectionViewDataSource.onDataChanged")
            self?.photoRibbonView.reloadData()
        }
        
        photoRibbonView.dataSource = photosRibbonDataSource
        photoRibbonView.delegate = self
        
        addSubview(photoView)
        addSubview(photoRibbonView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(flashView)
        
        setMode(.Capture)
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
        
        let freeSpaceUnderCamera = bounds.bottom - cameraFrame.bottom
        let canFitExtendedControls = (freeSpaceUnderCamera >= controlsExtendedHeight)
        let controlsHeight = canFitExtendedControls ? controlsExtendedHeight : controlsCompactHeight
        
        photoView.frame = cameraFrame
        cameraPreviewLayer?.frame = cameraFrame
        
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: controlsHeight
        )
        
        photoControlsView.frame = cameraControlsView.frame

        let photoRibbonHeight = max(photoRibbonMinHeight, cameraControlsView.top - photoView.bottom)

        photoRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: photoRibbonHeight
        )

        photoRibbonView.alpha = (cameraControlsView.top < cameraFrame.bottom) ? 0.25 /* TODO */ : 1

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
    var onPhotoSelect: (PhotoPickerItem -> ())?
    
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
    
    func setMode(mode: CameraViewMode) {
        
        switch mode {
        
        case .Capture:
            photoView.hidden = true
            photoView.image = nil
            
            cameraControlsView.hidden = false
            photoControlsView.hidden = true
            
            setCameraVisible(true)
        
        case .Preview(let photo):
            photoView.hidden = false
            photoView.setImage(photo.image)
            
            cameraControlsView.hidden = true
            photoControlsView.hidden = false
            
            setCameraVisible(false)
        }
    }
    
    func setCaptureSession(session: AVCaptureSession) {
        
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraPreviewLayer.backgroundColor = UIColor.blackColor().CGColor
        cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        layer.insertSublayer(cameraPreviewLayer, atIndex: 0)
        
        self.cameraPreviewLayer = cameraPreviewLayer
    }
    
    func setLatestPhotoLibraryItemImage(image: LazyImage?) {
        cameraControlsView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(visible: Bool) {
        cameraControlsView.setFlashButtonVisible(visible)
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
    
    func addPhoto(photo: PhotoPickerItem) {
        photosRibbonDataSource.addPhoto(photo)
    }
    
    func removeSelectionInPhotoRibbon() {
        photoRibbonView.indexPathsForSelectedItems()?.forEach { indexPath in
            photoRibbonView.deselectItemAtIndexPath(indexPath, animated: false)
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
        
        cameraControlsView.setControlsTransform(transform)
        photoControlsView.setControlsTransform(transform)
        
        photoRibbonLayout.itemsTransform = transform
        photoRibbonLayout.invalidateLayout()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = photosRibbonDataSource.photoAtIndexPath(indexPath)
        onPhotoSelect?(photo)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = photoRibbonView.height - photoRibbonInsets.top - photoRibbonInsets.bottom
        return CGSize(width: height, height: height)
    }
    
    // MARK: - Private
    
    private func setCameraVisible(visible: Bool) {
        cameraPreviewLayer?.hidden = !visible
        onCameraVisibilityChange?(isCameraVisible: visible)
    }
}