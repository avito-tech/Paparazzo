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
    private let accessDeniedView = AccessDeniedView()
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(cellReuseIdentifier: "PhotoLibraryItemCell")
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        dataSource.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
        }
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
        
        accessDeniedView.frame = CGRect(origin: .zero, size: accessDeniedView.sizeForWidth(bounds.size.width * 0.8))
        accessDeniedView.center = bounds.center
    }
    
    // MARK: - PhotoLibraryView
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    func setCellsData(items: [PhotoLibraryItemCellData]) {
        dataSource.setItems(items)
    }
    
    func scrollToBottom() {
        dispatch_async(dispatch_get_main_queue()) { [collectionView] in
            collectionView.scrollToBottom()
        }
    }
    
    func setTheme(theme: PhotoLibraryUITheme) {
        self.theme = theme
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
        cell.selectedBorderColor = theme?.photoLibraryItemSelectionColor
        
        // Без этого костыля невозможно снять выделение с preselected ячейки
        if data.selected {
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
}