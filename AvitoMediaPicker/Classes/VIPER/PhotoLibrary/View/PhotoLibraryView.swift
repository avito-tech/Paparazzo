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
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: PhotoLibraryLayout())
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(cellReuseIdentifier: "PhotoLibraryItemCell")
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        dataSource.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
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
    
    // MARK: - PhotoLibraryView
    
    func setCellsData(items: [PhotoLibraryItemCellData]) {
        dataSource.setItems(items)
    }
    
    func scrollToBottom() {
        dispatch_async(dispatch_get_main_queue()) { [collectionView] in
            collectionView.scrollToBottom()
        }
    }
    
    func setTheme(theme: PhotoLibraryUITheme) {
        dataSource.additionalCellConfiguration = { cell, item in
            cell.selectedBorderColor = theme.photoLibraryItemSelectionColor
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        adjustDimmingForCell(cell)
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canSelectMoreItems
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        dataSource.mutateItem(atIndexPath: indexPath) { $0.selected = true }
        dataSource.item(atIndexPath: indexPath).onSelect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        dataSource.mutateItem(atIndexPath: indexPath) { $0.selected = false }
        dataSource.item(atIndexPath: indexPath).onDeselect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    // MARK: - Private
    
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
}