import UIKit

final class PhotoLibraryView: UIView, UICollectionViewDelegateFlowLayout, ThemeConfigurable {
    
    typealias ThemeType = PhotoLibraryUITheme
    
    private enum AlbumsListState {
        case collapsed
        case expanded
    }
    
    // MARK: - State
    
    private var albumsListState: AlbumsListState = .collapsed
    
    var canSelectMoreItems = false
    
    var dimsUnselectedItems = false {
        didSet {
            adjustDimmingForVisibleCells()
        }
    }
    
    // MARK: - Subviews
    
    private let layout = PhotoLibraryLayout()
    private var collectionView: UICollectionView
    private let titleView = PhotoLibraryTitleView()
    private let accessDeniedView = AccessDeniedView()
    private let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private let toolbar = PhotoLibraryToolbar()
    private let dimView = UIView()
    private let albumsTableView = PhotoLibraryAlbumsTableView()
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(cellReuseIdentifier: "PhotoLibraryItemCell")
    
    // MARK: - Init
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)

        dataSource.additionalCellConfiguration = { [weak self] cell, data, collectionView, indexPath in
            self?.configureCell(cell, wihData: data, inCollectionView: collectionView, atIndexPath: indexPath)
        }
        
        backgroundColor = .white
        
        setUpCollectionView()
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTitleViewTap(_:))))
        
        accessDeniedView.isHidden = true
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDimViewTap(_:))))
        
        addSubview(collectionView)
        addSubview(accessDeniedView)
        addSubview(toolbar)
        addSubview(dimView)
        addSubview(albumsTableView)
        addSubview(titleView)
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.color = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
        
        addSubview(progressIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let titleViewSize = titleView.sizeThatFits(bounds.size)
        let toolbarSize = toolbar.sizeThatFits(bounds.size)
        
        titleView.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: titleViewSize.height
        )
        
        toolbar.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: toolbarSize.height
        )
        
        collectionView.layout(
            left: bounds.left,
            right: bounds.right,
            top: titleView.bottom,
            bottom: toolbar.top
        )
        
        albumsTableView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: titleView.bottom,
            height: bounds.height - titleView.height
        )
        
        dimView.frame = bounds
        
        accessDeniedView.frame = collectionView.bounds
        
        progressIndicator.center = bounds.center
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        titleView.setLabelFont(theme.photoLibraryTitleFont)
        titleView.setIcon(theme.photoLibraryAlbumsDisclosureIcon)
        
        accessDeniedView.setTheme(theme)
        
        toolbar.setDiscardButtonIcon(theme.photoLibraryDiscardButtonIcon)
        toolbar.setConfirmButtonIcon(theme.photoLibraryConfirmButtonIcon)
        
        albumsTableView.setCellLabelFont(theme.photoLibraryAlbumCellFont)
    }
    
    // MARK: - PhotoLibraryView
    
    var onDiscardButtonTap: (() -> ())? {
        get { return toolbar.onDiscardButtonTap }
        set { toolbar.onDiscardButtonTap = newValue }
    }
    
    var onConfirmButtonTap: (() -> ())? {
        get { return toolbar.onConfirmButtonTap }
        set { toolbar.onConfirmButtonTap = newValue }
    }
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    var onTitleTap: (() -> ())?
    var onDimViewTap: (() -> ())?
    
    func applyChanges(_ changes: PhotoLibraryViewChanges, animated: Bool, completion: (() -> ())?) {
        
        ObjCExceptionCatcher.tryClosure(
            tryClosure: { [collectionView, dataSource] in
                collectionView.performBatchUpdates(animated: animated, {
                    
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
            },
            catchClosure: { _ in
                self.recreateCollectionView()
            }
        )
    }
    
    func deselectAndAdjustAllCells() {
        
        guard let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems
            else { return }
        
        for indexPath in indexPathsForSelectedItems {
            collectionView.deselectItem(at: indexPath, animated: false)
            onDeselectItem(at: indexPath)
        }
    }
    
    func scrollToBottom() {
        collectionView.scrollToBottom()
    }
    
    func setTitle(_ title: String) {
        titleView.setTitle(title)
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
    
    func setProgressVisible(_ visible: Bool) {
        if visible {
            progressIndicator.startAnimating()
        } else {
            progressIndicator.stopAnimating()
        }
    }
    
    func setAlbums(_ albums: [PhotoLibraryAlbumCellData]) {
        albumsTableView.setCellDataList(albums)
        setNeedsLayout()
    }
    
    func showAlbumsList() {
        UIView.animate(withDuration: 0.25) {
            self.albumsListState = .expanded
            self.dimView.alpha = 1
            self.albumsTableView.top = self.titleView.bottom
            self.titleView.rotateIconUp()
        }
    }
    
    func hideAlbumsList() {
        UIView.animate(withDuration: 0.25) {
            self.albumsListState = .collapsed
            self.dimView.alpha = 0
            self.albumsTableView.bottom = self.titleView.bottom
            self.titleView.rotateIconDown()
        }
    }
    
    func toggleAlbumsList() {
        switch albumsListState {
        case .collapsed:
            showAlbumsList()
        case .expanded:
            hideAlbumsList()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        adjustDimmingForCell(cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cellData = dataSource.item(at: indexPath)
        
        cellData.onSelectionPrepare?()
        
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
        onDeselectItem(at: indexPath)
    }
    
    // MARK: - Private
    
    private var theme: PhotoLibraryUITheme?
    
    private func setUpCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            PhotoLibraryItemCell.self,
            forCellWithReuseIdentifier: dataSource.cellReuseIdentifier
        )
    }
    
    private func recreateCollectionView() {
        
        // Save the previously visible bounds
        let oldBounds = collectionView.bounds
        
        // Prepare a collection view snapshot
        let collectionViewSnapshot = collectionView.snapshotView(afterScreenUpdates: false)
        collectionViewSnapshot?.frame = collectionView.frame
        
        collectionView.removeFromSuperview()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        setUpCollectionView()
        addSubview(collectionView)
        
        // Display a collection view snapshot to improve user experience
        if let snapshot = collectionViewSnapshot {
            collectionView.superview?.addSubview(snapshot)
        }
        
        // Reload the data in a non-animated fashion
        collectionView.reloadData()
        
        // Add a delay before scrolling to previously visible bounds, or it will not work
        OperationQueue.main.addOperation {
            // Scroll to previously visible bounds
            self.collectionView.scrollRectToVisible(oldBounds, animated: false)
            
            // Animate snapshot fading out
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    collectionViewSnapshot?.alpha = 0
                }, completion: { _ in
                    collectionViewSnapshot?.removeFromSuperview()
                }
            )
        }
    }
    
    private func adjustDimmingForCell(_ cell: UICollectionViewCell) {
        let shouldDimCell = (dimsUnselectedItems && !cell.isSelected)
        cell.contentView.alpha = shouldDimCell ? 0.3 : 1
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
    
    private func onDeselectItem(at indexPath: IndexPath) {
        dataSource.mutateItem(at: indexPath) { (cellData: inout PhotoLibraryItemCellData) in
            cellData.selected = false
        }
        dataSource.item(at: indexPath).onDeselect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
    }
    
    @objc private func onTitleViewTap(_: UITapGestureRecognizer) {
        onTitleTap?()
    }
    
    @objc private func onDimViewTap(_: UITapGestureRecognizer) {
        onDimViewTap?()
    }
}
