import ImageSource
import UIKit

final class ThumbnailsView: UIView, UICollectionViewDataSource, MediaRibbonLayoutDelegate, ThemeConfigurable {
    
    typealias ThemeType = MediaPickerRootModuleUITheme
   
    var onDragStart: (() -> ())? {
        get {
            return layout.onDragStart
        }
        set {
            layout.onDragStart = newValue
        }
    }
    
    var onDragFinish: (() -> ())? {
        get {
            return layout.onDragFinish
        }
        set {
            layout.onDragFinish = newValue
        }
    }
    
    private let layout: ThumbnailsViewLayout
    private let collectionView: UICollectionView
    private let dataSource = MediaRibbonDataSource()
    
    private var theme: MediaPickerRootModuleUITheme?
    
    // MARK: - Constrants
    
    private let mediaRibbonInteritemSpacing = CGFloat(7)
    
    private let photoCellReuseId = "PhotoCell"
    private let cameraCellReuseId = "CameraCell"
    
    // MARK: - Init
    
    init() {
        
        layout = ThumbnailsViewLayout()
        layout.spacing = mediaRibbonInteritemSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(MediaItemThumbnailCell.self, forCellWithReuseIdentifier: photoCellReuseId)
        collectionView.register(CameraThumbnailCell.self, forCellWithReuseIdentifier: cameraCellReuseId)
        
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
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
    }
    
    // MARK: - ThumbnailRibbonView
    
    var cameraOutputParameters: CameraOutputParameters? {
        didSet {
            updateCameraCell()
        }
    }
    
    var contentInsets = UIEdgeInsets.zero {
        didSet {
            layout.sectionInset = contentInsets
        }
    }
    
    var onPhotoItemSelect: ((MediaPickerItem) -> ())?
    var onItemMove: ((Int, Int) -> ())?
    var onCameraItemSelect: (() -> ())?
    
    func selectCameraItem() {
        collectionView.selectItem(at: dataSource.indexPathForCameraItem(), animated: false, scrollPosition: [])
    }
    
    func selectMediaItem(_ item: MediaPickerItem, animated: Bool = false) {
        layout.cancelDrag()
        
        if let indexPath = dataSource.indexPathForItem(item) {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
    
    func scrollToItemThumbnail(_ item: MediaPickerItem, animated: Bool) {
        if let indexPath = dataSource.indexPathForItem(item) {
            collectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: animated
            )
        }
    }
    
    func scrollToCameraThumbnail(animated: Bool) {
        collectionView.scrollToItem(
            at: dataSource.indexPathForCameraItem(),
            at: .centeredHorizontally,
            animated: animated
        )
    }
    
    func setControlsTransform(_ transform: CGAffineTransform) {
        
        layout.itemsTransform = transform
        layout.invalidateLayout()
        
        cameraIconTransform = transform
    }
    
    func setHapticFeedbackEnabled(_ enabled: Bool) {
        layout.hapticFeedbackEnabled = enabled
    }
    
    func addItems(_ items: [MediaPickerItem], animated: Bool, completion: @escaping () -> ()) {
        collectionView.performBatchUpdates(
            animated: animated,
            updates: { [weak self] in
                if let indexPaths = self?.dataSource.addItems(items) {
                    self?.collectionView.insertItems(at: indexPaths)
                    
                    if let indexPathsToReload = self?.collectionView.indexPathsForVisibleItems.filter({ !indexPaths.contains($0) }),
                        indexPathsToReload.count > 0
                    {
                        self?.collectionView.reloadItems(at: indexPathsToReload)
                    }
                }
            },
            completion: { _ in
                completion()
            }
        )
    }
    
    func updateItem(_ item: MediaPickerItem) {
        
        if let indexPath = dataSource.updateItem(item) {
            
            let selectedIndexPaths = collectionView.indexPathsForSelectedItems
            let cellWasSelected = selectedIndexPaths?.contains(indexPath) == true
            
            collectionView.reloadItems(at: [indexPath])
            
            if cellWasSelected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }
    
    func removeItem(_ item: MediaPickerItem, animated: Bool) {
        collectionView.deleteItems(animated: animated) { [weak self] in
            self?.dataSource.removeItem(item).flatMap { [$0] }
        }
    }
    
    func moveItemThumbnail(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        collectionView.performBatchUpdates(animated: false, updates: { [weak self] in
            self?.dataSource.moveItem(
                from: sourceIndex,
                to: destinationIndex
            )
            
            self?.collectionView.moveItem(
                at: IndexPath(item: sourceIndex, section: 0),
                to: IndexPath(item: destinationIndex, section: 0)
            )
        })
    }
    
    func setCameraItemVisible(_ visible: Bool) {
        
        if dataSource.cameraCellVisible != visible {
            
            let updatesFunction = { [weak self] () -> [IndexPath]? in
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
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters) {
        cameraOutputParameters = parameters
    }
    
    func setCameraOutputOrientation(_ orientation: ExifOrientation) {
        cameraOutputParameters?.orientation = orientation
        if let cell = cameraCell() {
            cell.setOutputOrientation(orientation)
        }
    }
    
    func reloadCamera() {
        if dataSource.cameraCellVisible {
            let cameraIndexPath = dataSource.indexPathForCameraItem()
            let cameraIsSelected = collectionView.indexPathsForSelectedItems?.contains(cameraIndexPath) == true
            
            collectionView.performNonAnimatedBatchUpdates(
                updates: {
                    self.collectionView.reloadItems(at: [cameraIndexPath])
                },
                completion: { _ in
                    if cameraIsSelected {
                        self.collectionView.selectItem(at: cameraIndexPath, animated: false, scrollPosition: [])
                    }
                }
            )
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch dataSource[indexPath] {
        case .camera:
            return cameraCell(forIndexPath: indexPath, inCollectionView: collectionView)
        case .photo(let mediaPickerItem):
            return photoCell(forIndexPath: indexPath, inCollectionView: collectionView, withItem: mediaPickerItem)
        }
    }
    
    // MARK: - MediaRibbonLayoutDelegate
    
    func shouldApplyTransformToItemAtIndexPath(_ indexPath: IndexPath) -> Bool {
        switch dataSource[indexPath] {
        case .photo:
            return true
        case .camera:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch dataSource[indexPath] {
        case .photo(let photo):
            onPhotoItemSelect?(photo)
        case .camera:
            onCameraItemSelect?()
        }
    }
    
    func canMove(to indexPath: IndexPath) -> Bool {
        let cameraCellVisible = dataSource.cameraCellVisible ? 1 : 0
        
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastItemIndex = collectionView.numberOfItems(inSection: lastSectionIndex) - cameraCellVisible
        let lastIndexPath = IndexPath(item: lastItemIndex, section: lastSectionIndex)
        
        return indexPath != lastIndexPath
    }
    
    func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        onItemMove?(sourceIndexPath.item, destinationIndexPath.item)
        dataSource.moveItem(from: sourceIndexPath.item, to: destinationIndexPath.item)
    }
    
    
    // MARK: - Private
    
    private var cameraIconTransform = CGAffineTransform.identity {
        didSet {
            cameraCell()?.setCameraIconTransform(cameraIconTransform)
        }
    }
    
    private func photoCell(
        forIndexPath indexPath: IndexPath,
        inCollectionView collectionView: UICollectionView,
        withItem mediaPickerItem: MediaPickerItem
    ) -> UICollectionViewCell {
        
        let cell = collectionView.cellForItem(at: indexPath) ?? collectionView.dequeueReusableCell(
            withReuseIdentifier: photoCellReuseId,
            for: indexPath
        )
        
        if let cell = cell as? MediaItemThumbnailCell {
            cell.selectedBorderColor = theme?.mediaRibbonSelectionColor
            cell.customizeWithItem(mediaPickerItem)
            cell.setAccessibilityId("\(AccessibilityId.mediaItemThumbnailCell)-\(indexPath.row)")
        }
        
        return cell
    }
    
    private func cameraCell(
        forIndexPath indexPath: IndexPath,
        inCollectionView collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cameraCellReuseId,
            for: indexPath
        )
        
        setUpCameraCell(cell)
        
        return cell
    }
    
    private func setUpCameraCell(_ cell: UICollectionViewCell) {
        if let cell = cell as? CameraThumbnailCell {
            cell.selectedBorderColor = theme?.mediaRibbonSelectionColor
            cell.setCameraIcon(theme?.returnToCameraIcon)
            cell.setCameraIconTransform(cameraIconTransform)
            
            if let cameraOutputParameters = cameraOutputParameters, !isHidden {
                cell.setOutputParameters(cameraOutputParameters)
            }
        }
    }
    
    private func updateCameraCell() {
        if let cell = cameraCell() {
            setUpCameraCell(cell)
        }
    }
    
    private func cameraCell() -> CameraThumbnailCell? {
        let indexPath = dataSource.indexPathForCameraItem()
        return collectionView.cellForItem(at: indexPath) as? CameraThumbnailCell
    }
}
