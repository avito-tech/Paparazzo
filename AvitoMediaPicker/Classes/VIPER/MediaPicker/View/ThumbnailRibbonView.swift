import UIKit
import AVFoundation

final class ThumbnailRibbonView: UIView, UICollectionViewDataSource, MediaRibbonLayoutDelegate {
    
    private let layout: MediaRibbonLayout
    private let collectionView: UICollectionView
    private let dataSource = MediaRibbonDataSource()
    
    private var theme: MediaPickerRootModuleUITheme?
    
    // MARK: - Constrants
    
    private let mediaRibbonInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    private let mediaRibbonInteritemSpacing = CGFloat(7)
    
    private let photoCellReuseId = "PhotoCell"
    private let cameraCellReuseId = "CameraCell"
    
    // MARK: - Init
    
    init() {
        
        layout = MediaRibbonLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = mediaRibbonInsets
        layout.minimumLineSpacing = mediaRibbonInteritemSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerClass(MediaRibbonCell.self, forCellWithReuseIdentifier: photoCellReuseId)
        collectionView.registerClass(CameraCell.self, forCellWithReuseIdentifier: cameraCellReuseId)
        
        super.init(frame: .zero)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    // MARK: - ThumbnailRibbonView
    
    var captureSession: AVCaptureSession? {
        didSet {
            updateCameraCell()
        }
    }
    
    var onPhotoItemSelect: (MediaPickerItem -> ())?
    var onCameraItemSelect: (() -> ())?
    
    func selectCameraItem() {
        collectionView.selectItemAtIndexPath(dataSource.indexPathForCameraItem(), animated: false, scrollPosition: .None)
    }
    
    func selectMediaItem(item: MediaPickerItem, animated: Bool = false) {
        if let indexPath = dataSource.indexPathForItem(item) {
            collectionView.selectItemAtIndexPath(indexPath, animated: animated, scrollPosition: .None)
        }
    }
    
    func setTheme(theme: MediaPickerRootModuleUITheme) {
        self.theme = theme
    }
    
    func setControlsTransform(transform: CGAffineTransform) {
        
        layout.itemsTransform = transform
        layout.invalidateLayout()
        
        cameraIconTransform = transform
    }
    
    func addItems(items: [MediaPickerItem], animated: Bool) {
        collectionView.insertItems(animated: animated) { [weak self] in
            self?.dataSource.addItems(items)
        }
    }
    
    func removeItem(item: MediaPickerItem, animated: Bool) {
        collectionView.deleteItems(animated: animated) { [weak self] in
            self?.dataSource.removeItem(item).flatMap { [$0] }
        }
    }
    
    func setCameraItemVisible(visible: Bool) {
        
        if dataSource.cameraCellVisible != visible {
            
            let updatesFunction = { [weak self] () -> [NSIndexPath]? in
                self?.dataSource.cameraCellVisible = visible
                return (self?.dataSource.indexPathForCameraItem()).flatMap { [$0] }
            }
            
            if visible {
                collectionView.insertItems(animated: false, updatesFunction)
            } else {
                collectionView.deleteItems(animated: false, updatesFunction)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch dataSource[indexPath] {
        case .Camera:
            return cameraCell(forIndexPath: indexPath, inCollectionView: collectionView)
        case .Photo(let mediaPickerItem):
            return photoCell(forIndexPath: indexPath, inCollectionView: collectionView, withItem: mediaPickerItem)
        }
    }
    
    // MARK: - MediaRibbonLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = bounds.size.height - mediaRibbonInsets.top - mediaRibbonInsets.bottom
        return CGSize(width: height, height: height)
    }
    
    func shouldApplyTransformToItemAtIndexPath(indexPath: NSIndexPath) -> Bool {
        switch dataSource[indexPath] {
        case .Photo(_):
            return true
        default:
            return false
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch dataSource[indexPath] {
        case .Photo(let photo):
            onPhotoItemSelect?(photo)
        case .Camera:
            onCameraItemSelect?()
        }
    }
    
    // MARK: - Private
    
    private var cameraIconTransform = CGAffineTransformIdentity {
        didSet {
            cameraCell()?.setCameraIconTransform(cameraIconTransform)
        }
    }
    
    private func photoCell(
        forIndexPath indexPath: NSIndexPath,
        inCollectionView collectionView: UICollectionView,
        withItem mediaPickerItem: MediaPickerItem
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            photoCellReuseId,
            forIndexPath: indexPath
        )
        
        if let cell = cell as? MediaRibbonCell {
            cell.selectedBorderColor = theme?.mediaRibbonSelectionColor
            cell.customizeWithItem(mediaPickerItem)
        }
        
        return cell
    }
    
    private func cameraCell(
        forIndexPath indexPath: NSIndexPath,
        inCollectionView collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            cameraCellReuseId,
            forIndexPath: indexPath
        )
        
        setUpCameraCell(cell)
        
        return cell
    }
    
    private func setUpCameraCell(cell: UICollectionViewCell) {
        if let cell = cell as? CameraCell, captureSession = captureSession {
            cell.selectedBorderColor = theme?.mediaRibbonSelectionColor
            cell.setCameraIcon(theme?.returnToCameraIcon)
            cell.setCameraIconTransform(cameraIconTransform)
            cell.setCaptureSession(captureSession)
        }
    }
    
    private func updateCameraCell() {
        if let cell = cameraCell() {
            setUpCameraCell(cell)
        }
    }
    
    private func cameraCell() -> CameraCell? {
        let indexPath = dataSource.indexPathForCameraItem()
        return collectionView.cellForItemAtIndexPath(indexPath) as? CameraCell
    }
}
