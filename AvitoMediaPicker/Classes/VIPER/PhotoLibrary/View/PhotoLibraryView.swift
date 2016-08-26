import UIKit

final class PhotoLibraryView: UIView, UICollectionViewDelegateFlowLayout {
    
    // MARK: - State
    
    var canSelectMoreItems = false
    
    var dimsUnselectedItems = false {
        didSet {
            adjustDimmingForVisibleCells()
        }
    }
    
    // MARK: - Subviews
    
    private let layout = PhotoLibraryLayout()
    private let collectionView: UICollectionView
    private let accessDeniedView = AccessDeniedView()
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(cellReuseIdentifier: "PhotoLibraryItemCell")
    
    // MARK: - Init
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)

        dataSource.additionalCellConfiguration = { [weak self] cell, data, collectionView, indexPath in
            self?.configureCell(cell, wihData: data, inCollectionView: collectionView, atIndexPath: indexPath)
        }
        
        backgroundColor = .whiteColor()
        
        collectionView.backgroundColor = .whiteColor()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.registerClass(
            PhotoLibraryItemCell.self,
            forCellWithReuseIdentifier: dataSource.cellReuseIdentifier
        )
        
        accessDeniedView.hidden = true
        
        addSubview(collectionView)
        addSubview(accessDeniedView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        accessDeniedView.frame = bounds
    }
    
    // MARK: - PhotoLibraryView
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    func applyChanges(changes: PhotoLibraryViewChanges, completion: (() -> ())?) {
        
        collectionView.performBatchUpdates({ [collectionView, dataSource] in
            
            let toIndexPath = { (index: Int) in
                NSIndexPath(forItem: index, inSection: 0)
            }
            
            // Order is important!
            // 1. Removing items
            let indexPathsToDelete = changes.removedIndexes.map(toIndexPath)
            
            if indexPathsToDelete.count > 0 {
                collectionView.deleteItemsAtIndexPaths(indexPathsToDelete)
                dataSource.deleteItems(at: indexPathsToDelete)
            }
            
            // 2. Inserting items
            let indexPathsToInsert = changes.insertedItems.map { toIndexPath($0.index) }
            
            if indexPathsToInsert.count > 0 {
                collectionView.insertItemsAtIndexPaths(indexPathsToInsert)
                dataSource.insertItems(changes.insertedItems.map { item in
                    (item: item.cellData, indexPath: toIndexPath(item.index))
                })
            }
            
            // 3. Updating items
            let indexPathsToUpdate = changes.updatedItems.map { toIndexPath($0.index) }
            
            if indexPathsToUpdate.count > 0 {
                collectionView.reloadItemsAtIndexPaths(indexPathsToUpdate)
                
                changes.updatedItems.forEach { index, newCellData in
                    
                    let indexPath = toIndexPath(index)
                    let oldCellData = dataSource.item(at: indexPath)
                    
                    var newCellData = newCellData
                    newCellData.selected = oldCellData.selected     // preserving selection
                    
                    dataSource.replaceItem(at: indexPath, with: newCellData)
                }
            }
            
            // 4. Moving items
            changes.movedIndexes.forEach { from, to in
                let sourceIndexPath = toIndexPath(from)
                let targetIndexPath = toIndexPath(to)
                
                collectionView.moveItemAtIndexPath(sourceIndexPath, toIndexPath: targetIndexPath)
                dataSource.moveItem(at: sourceIndexPath, to: targetIndexPath)
            }
            
        }, completion: { _ in
            completion?()
        })
    }
    
    func scrollToBottom() {
        dispatch_async(dispatch_get_main_queue()) { [collectionView] in
            collectionView.scrollToBottom()
        }
    }
    
    func setTheme(theme: PhotoLibraryUITheme) {
        self.theme = theme
        accessDeniedView.setTheme(theme)
    }
    
    func setAccessDeniedViewVisible(visible: Bool) {
        accessDeniedView.hidden = !visible
    }
    
    func setAccessDeniedTitle(title: String) {
        accessDeniedView.title = title
    }
    
    func setAccessDeniedMessage(message: String) {
        accessDeniedView.message = message
    }
    
    func setAccessDeniedButtonTitle(title: String) {
        accessDeniedView.buttonTitle = title
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        adjustDimmingForCell(cell)
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cellData = dataSource.item(at: indexPath)
        return canSelectMoreItems && cellData.previewAvailable
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        dataSource.mutateItem(atIndexPath: indexPath) { $0.selected = true }
        dataSource.item(at: indexPath).onSelect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        dataSource.mutateItem(atIndexPath: indexPath) { $0.selected = false }
        dataSource.item(at: indexPath).onDeselect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    // MARK: - Private
    
    private var theme: PhotoLibraryUITheme?
    
    private func adjustDimmingForCell(cell: UICollectionViewCell) {
        let shouldDimCell = (dimsUnselectedItems && !cell.selected)
        cell.contentView.alpha = shouldDimCell ? 0.3 /* TODO: взято с потолка, нужно взять с пола */ : 1
    }
    
    private func adjustDimmingForCellAtIndexPath(indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            adjustDimmingForCell(cell)
        }
    }
    
    private func adjustDimmingForVisibleCells() {
        collectionView.visibleCells().forEach { adjustDimmingForCell($0) }
    }
    
    private func configureCell(
        cell: PhotoLibraryItemCell,
        wihData data: PhotoLibraryItemCellData,
        inCollectionView collectionView: UICollectionView,
        atIndexPath indexPath: NSIndexPath
    ) {
        cell.backgroundColor = theme?.photoCellBackgroundColor
        cell.selectedBorderColor = theme?.photoLibraryItemSelectionColor
        
        cell.setCloudIcon(theme?.iCloudIcon)
        
        cell.onImageSetFromSource = { [weak self] in
            self?.dataSource.mutateItem(atIndexPath: indexPath) { cellData in
                cellData.previewAvailable = true
            }
        }
        
        // Без этого костыля невозможно снять выделение с preselected ячейки
        if data.selected {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
}