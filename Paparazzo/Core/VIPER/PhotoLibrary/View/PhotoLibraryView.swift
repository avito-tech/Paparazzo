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
    private var collectionSnapshotView: UIView?
    private let titleView = PhotoLibraryTitleView()
    private let accessDeniedView = AccessDeniedView()
    private let progressIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let toolbar = PhotoLibraryToolbar()
    private let dimView = UIView()
    private let albumsTableView = PhotoLibraryAlbumsTableView()
    private let placeholderView = UILabel()
    
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
        
        placeholderView.isHidden = true
        
        addSubview(collectionView)
        addSubview(placeholderView)
        addSubview(accessDeniedView)
        addSubview(toolbar)
        addSubview(dimView)
        addSubview(albumsTableView)
        addSubview(titleView)
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.color = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
        
        addSubview(progressIndicator)
        
        setUpAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpAccessibilityIdentifiers() {
        accessibilityIdentifier = AccessibilityId.photoLibrary.rawValue
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
        
        placeholderView.resizeToFitSize(collectionView.size)
        placeholderView.center = collectionView.center
        
        collectionSnapshotView?.frame = collectionView.frame
        
        layoutAlbumsTableView()
        
        dimView.frame = bounds
        
        accessDeniedView.frame = collectionView.bounds
        
        progressIndicator.center = bounds.center
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        collectionView.backgroundColor = theme.photoLibraryCollectionBackgroundColor
        
        titleView.setLabelFont(theme.photoLibraryTitleFont)
        titleView.setIcon(theme.photoLibraryAlbumsDisclosureIcon)
        titleView.backgroundColor = theme.photoLibraryCollectionBackgroundColor
        
        accessDeniedView.setTheme(theme)
        
        toolbar.setDiscardButtonIcon(theme.photoLibraryDiscardButtonIcon)
        toolbar.setConfirmButtonIcon(theme.photoLibraryConfirmButtonIcon)
        toolbar.backgroundColor = theme.photoLibraryCollectionBackgroundColor
        
        albumsTableView.setCellLabelFont(theme.photoLibraryAlbumCellFont)
        albumsTableView.setCellBackgroundColor(theme.photoLibraryAlbumsTableViewCellBackgroundColor)
        albumsTableView.setTableViewBackgroundColor(theme.photoLibraryAlbumsTableViewBackgroundColor)

        placeholderView.font = theme.photoLibraryPlaceholderFont
        placeholderView.textColor = theme.photoLibraryPlaceholderColor
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
    
    func setItems(_ items: [PhotoLibraryItemCellData], scrollToBottom: Bool, completion: (() -> ())?) {
        
        // If `items` contain a lot of elements, then there's a chance that by the time
        // `collectionView.scrollToBottom()` is called in `performBatchUpdates` completion, the user will see
        // some of the new content, followed by a fast jump to the bottom. To prevent this unwanted glitch
        // we need to cover collection view with a snapshot of its current content. This snapshot will be removed
        // after `scrollToBottom()`.
        if scrollToBottom {
            coverCollectionViewWithItsSnapshot()
        }
        
        // Delete existing items outside `performBatchUpdates`, otherwise there will be UI bug on scrollToBottom
        // (collection view will be scrolled to an empty space below it's actual content)
        dataSource.deleteAllItems()
        collectionView.reloadData()
        
        ObjCExceptionCatcher.tryClosure(
            tryClosure: { [collectionView, collectionSnapshotView, dataSource] in
                collectionView.performBatchUpdates(
                    animated: true,
                    updates: {
                        let indexPathsToInsert = (0 ..< items.count).map { IndexPath(item: $0, section: 0) }
                        collectionView.insertItems(at: indexPathsToInsert)
                        
                        dataSource.setItems(items)
                    },
                    completion: { _ in
                        if scrollToBottom {
                            collectionView.scrollToBottom()
                            collectionSnapshotView?.removeFromSuperview()
                        }
                        completion?()
                    }
                )
            },
            catchClosure: { _ in
                self.recreateCollectionView()
                completion?()
            }
        )
    }
    
    func applyChanges(_ changes: PhotoLibraryViewChanges, completion: (() -> ())?) {
        
        ObjCExceptionCatcher.tryClosure(
            tryClosure: { [collectionView, dataSource] in
                collectionView.performBatchUpdates(animated: true, updates: {
                    
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
                completion?()
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
    
    func setTitleVisible(_ visible: Bool) {
        titleView.setTitleVisible(visible)
        titleView.isUserInteractionEnabled = visible
    }
    
    func setPlaceholderTitle(_ title: String) {
        placeholderView.text = title
    }
    
    func setPlaceholderVisible(_ visible: Bool) {
        placeholderView.isHidden = !visible
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
        albumsTableView.setCellDataList(albums) { [weak self] in
            self?.setNeedsLayout()
        }
    }
    
    func selectAlbum(withId id: String) {
        albumsTableView.selectAlbum(withId: id)
    }
    
    func showAlbumsList() {
        UIView.animate(withDuration: 0.25) {
            self.albumsListState = .expanded
            self.dimView.alpha = 1
            self.layoutAlbumsTableView()
            self.titleView.rotateIconUp()
        }
    }
    
    func hideAlbumsList() {
        UIView.animate(withDuration: 0.25) {
            self.albumsListState = .collapsed
            self.dimView.alpha = 0
            self.layoutAlbumsTableView()
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
        atIndexPath indexPath: IndexPath)
    {
        cell.backgroundColor = theme?.photoCellBackgroundColor
        cell.selectedBorderColor = theme?.photoLibraryItemSelectionColor
        
        cell.setCloudIcon(theme?.iCloudIcon)
        
        cell.onImageSetFromSource = { [weak self] in
            self?.dataSource.mutateItem(data, at: indexPath) { (data: inout PhotoLibraryItemCellData) in
                data.previewAvailable = true
            }
        }
        
        cell.setAccessibilityId(index: indexPath.row)

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
    
    private func coverCollectionViewWithItsSnapshot() {
        collectionSnapshotView = collectionView.snapshotView(afterScreenUpdates: false)
        collectionSnapshotView?.backgroundColor = collectionView.backgroundColor
        
        if let collectionSnapshotView = collectionSnapshotView {
            insertSubview(collectionSnapshotView, aboveSubview: collectionView)
        }
    }
    
    private func layoutAlbumsTableView() {
        
        let size = albumsTableView.sizeThatFits(CGSize(
            width: bounds.width,
            height: bounds.height - titleView.height
        ))
        
        let top: CGFloat
        
        switch albumsListState {
        case .collapsed:
            top = titleView.bottom - size.height
        case .expanded:
            top = titleView.bottom
        }
        
        albumsTableView.frame = CGRect(
            left: bounds.left,
            right: bounds.right,
            top: top,
            height: size.height
        )
    }
}
