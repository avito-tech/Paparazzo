import UIKit

final class PhotoLibraryView: UIView, UICollectionViewDelegateFlowLayout {
    
    // MARK: - State
    
    var canSelectMoreItems = true
    
    var dimUnselectedItems = true {
        didSet {
            collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems())
        }
    }
    
    // MARK: - Subviews
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: PhotoLibraryLayout())
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(
        cellReuseIdentifier: PhotoLibraryItemCell.reuseIdentifier
    )
    
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
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        adjustDimmingForCell(cell)
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canSelectMoreItems
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    // MARK: - Private
    
    private func adjustDimmingForCell(cell: UICollectionViewCell) {
        let shouldDimCell = (dimUnselectedItems && !cell.selected)
        cell.contentView.alpha = shouldDimCell ? 0.3 /* TODO: взято с потолка, нужно взять с пола */ : 1
    }
    
    private func adjustDimmingForCellAtIndexPath(indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            adjustDimmingForCell(cell)
        }
    }
}