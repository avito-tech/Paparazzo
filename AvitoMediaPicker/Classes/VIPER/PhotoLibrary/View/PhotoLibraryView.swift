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
        
        backgroundColor = .white
        
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            PhotoLibraryItemCell.self,
            forCellWithReuseIdentifier: dataSource.cellReuseIdentifier
        )
        
        accessDeniedView.isHidden = true
        
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
    
    func applyChanges(_ changes: PhotoLibraryViewChanges, animated: Bool, completion: (() -> ())?) {
        
        collectionView.performBatchUpdates(animated: animated, { [collectionView, dataSource] in
            
            let toIndexPath = { (index: Int) in
                IndexPath(item: index, section: 0)
            }
            
            // Order is important!
            // 1. Removing items
            let indexPathsToDelete = changes.removedIndexes.map(toIndexPath)
            
            if indexPathsToDelete.count > 0 {
                collectionView.deleteItems(at: indexPathsToDelete)
                dataSource.deleteItems(at: indexPathsToDelete)
            }
            
            // 2. Inserting items
            let indexPathsToInsert = changes.insertedItems.map { toIndexPath($0.index) }
            
            if indexPathsToInsert.count > 0 {
                collectionView.insertItems(at: indexPathsToInsert)
                dataSource.insertItems(changes.insertedItems.map { item in
                    (item: item.cellData, indexPath: toIndexPath(item.index))
                })
            }
            
            // 3. Updating items
            let indexPathsToUpdate = changes.updatedItems.map { toIndexPath($0.index) }
            
            if indexPathsToUpdate.count > 0 {
                collectionView.reloadItems(at: indexPathsToUpdate)
                
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
                
                collectionView.moveItem(at: sourceIndexPath, to: targetIndexPath)
                dataSource.moveItem(at: sourceIndexPath, to: targetIndexPath)
            }
            
        }, completion: { _ in
            completion?()
        })
    }
    
    func scrollToBottom() {
        collectionView.scrollToBottom()
    }
    
    func setTheme(_ theme: PhotoLibraryUITheme) {
        self.theme = theme
        accessDeniedView.setTheme(theme)
    }
    
    func setAccessDeniedViewVisible(_ visible: Bool) {
        accessDeniedView.isHidden = !visible
    }
    
    func setAccessDeniedTitle(_ title: String) {
        accessDeniedView.title = title
    }
    
    func setAccessDeniedMessage(_ message: String) {
        accessDeniedView.message = message
    }
    
    func setAccessDeniedButtonTitle(_ title: String) {
        accessDeniedView.buttonTitle = title
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        adjustDimmingForCell(cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cellData = dataSource.item(at: indexPath)
        return canSelectMoreItems && cellData.previewAvailable
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        dataSource.mutateItem(at: indexPath) { (cellData: inout PhotoLibraryItemCellData) in
            cellData.selected = true
        }
        dataSource.item(at: indexPath).onSelect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        dataSource.mutateItem(at: indexPath) { (cellData: inout PhotoLibraryItemCellData) in
            cellData.selected = false
        }
        dataSource.item(at: indexPath).onDeselect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    // MARK: - Private
    
    private var theme: PhotoLibraryUITheme?
    
    private func adjustDimmingForCell(_ cell: UICollectionViewCell) {
        let shouldDimCell = (dimsUnselectedItems && !cell.isSelected)
        cell.contentView.alpha = shouldDimCell ? 0.3 /* TODO: взято с потолка, нужно взять с пола */ : 1
    }
    
    private func adjustDimmingForCellAtIndexPath(_ indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            adjustDimmingForCell(cell)
        }
    }
    
    private func adjustDimmingForVisibleCells() {
        collectionView.visibleCells.forEach { adjustDimmingForCell($0) }
    }
    
    private func configureCell(
        _ cell: PhotoLibraryItemCell,
        wihData data: PhotoLibraryItemCellData,
        inCollectionView collectionView: UICollectionView,
        atIndexPath indexPath: IndexPath
    ) {
        cell.backgroundColor = theme?.photoCellBackgroundColor
        cell.selectedBorderColor = theme?.photoLibraryItemSelectionColor
        
        cell.setCloudIcon(theme?.iCloudIcon)
        
        cell.onImageSetFromSource = { [weak self] in
            self?.dataSource.mutateItem(at: indexPath) { (cellData: inout PhotoLibraryItemCellData) in
                cellData.previewAvailable = true
            }
        }
        
        // Без этого костыля невозможно снять выделение с preselected ячейки
        if data.selected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
    }
}
