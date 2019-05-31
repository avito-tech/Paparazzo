import ImageSource
import UIKit

final class PhotoLibraryV2View: UIView, UICollectionViewDelegateFlowLayout, ThemeConfigurable {
    
    typealias ThemeType = PhotoLibraryV2UITheme
    
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
    
    private var cameraViewData: PhotoLibraryCameraViewData?
    
    private var continueButtonPlacement = MediaPickerContinueButtonPlacement.topRight {
        didSet {
            switch continueButtonPlacement {
            case .topRight:
                bottomContinueButton.removeFromSuperview()
                bottomFadeView.removeFromSuperview()
                insertSubview(topRightContinueButton, belowSubview: progressIndicator)
            case .bottom:
                topRightContinueButton.removeFromSuperview()
                insertSubview(bottomContinueButton, belowSubview: albumsTableView)
                insertSubview(bottomFadeView, belowSubview: bottomContinueButton)
            }
        }
    }
    
    // MARK: - Subviews
    
    private let layout = PhotoLibraryV2Layout()
    private var collectionView: UICollectionView
    private var collectionSnapshotView: UIView?
    private let titleView = PhotoLibraryV2TitleView()
    private let accessDeniedView = AccessDeniedView()
    private let progressIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let dimView = UIView()
    private let albumsTableView = PhotoLibraryAlbumsTableView()
    private let placeholderView = UILabel()
    private let closeButton = UIButton()
    private let topRightContinueButton = UIButton()
    private let bottomContinueButton = UIButton()
    private let bottomFadeView = FadeView(gradientHeight: 80)
    
    // MARK: - Specs
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(
        cellReuseIdentifier: "PhotoLibraryItemCell",
        headerReuseIdentifier: "PhotoLibraryCameraView"
    )
    
    // MARK: - Init
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)

        configureDataSource()
        
        backgroundColor = .white
        
        setUpCollectionView()
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTitleViewTap(_:))))
        
        accessDeniedView.isHidden = true
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDimViewTap(_:))))
        
        placeholderView.isHidden = true
        
        setUpButtons()
        
        addSubview(collectionView)
        addSubview(placeholderView)
        addSubview(accessDeniedView)
        addSubview(dimView)
        addSubview(albumsTableView)
        addSubview(titleView)
        addSubview(closeButton)
        addSubview(topRightContinueButton)
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.color = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
        
        addSubview(progressIndicator)
        
        setUpAccessibilityIdentifiers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let fadeHeight = paparazzoSafeAreaInsets.bottom + bottomFadeView.gradientHeight
        
        closeButton.frame = CGRect(
            x: 8,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: closeButton.width,
            height: closeButton.height
        )
        
        topRightContinueButton.frame = CGRect(
            x: bounds.right - 8 - topRightContinueButton.width,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: topRightContinueButton.width,
            height: topRightContinueButton.height
        )
        
        bottomFadeView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: fadeHeight
        )
        
        bottomContinueButton.layout(
            left: bounds.left + 16,
            right: bounds.right - 16,
            bottom: bounds.bottom - paparazzoSafeAreaInsets.bottom - 16,
            height: 48
        )
        
        titleView.contentInsets = UIEdgeInsets(
            top: 0,
            left: closeButton.right + 10,
            bottom: 0,
            right: (continueButtonPlacement == .bottom)
                ? closeButton.right + 10  // same as left, so that it stays centered
                : bounds.width - topRightContinueButton.left + 10
        )
        
        let titleViewSize = titleView.sizeThatFits(bounds.size)
        
        titleView.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: titleViewSize.height
        )
        
        collectionView.layout(
            left: bounds.left,
            right: bounds.right,
            top: titleView.bottom,
            bottom: bounds.bottom
        )
        
        collectionView.contentInset.bottom = (continueButtonPlacement == .bottom) ? 80 : 16
        
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
        
        titleView.setLabelFont(theme.photoLibraryTitleFont)
        titleView.setIcon(theme.photoLibraryAlbumsDisclosureIcon)
        
        accessDeniedView.setTheme(theme)
        
        closeButton.setImage(theme.closeIcon, for: .normal)
        
        topRightContinueButton.setTitleColor(theme.continueButtonTitleColor, for: .normal)
        topRightContinueButton.titleLabel?.font = theme.continueButtonTitleFont
        
        topRightContinueButton.setTitleColor(
            theme.continueButtonTitleColor,
            for: .normal
        )
        topRightContinueButton.setTitleColor(
            theme.continueButtonTitleHighlightedColor,
            for: .highlighted
        )
        
        bottomContinueButton.backgroundColor = theme.libraryBottomContinueButtonBackgroundColor
        bottomContinueButton.titleLabel?.font = theme.libraryBottomContinueButtonFont
        bottomContinueButton.setTitleColor(theme.libraryBottomContinueButtonTitleColor, for: .normal)
        
        albumsTableView.setCellLabelFont(theme.photoLibraryAlbumCellFont)
        
        placeholderView.font = theme.photoLibraryPlaceholderFont
        placeholderView.textColor = theme.photoLibraryPlaceholderColor
    }
    
    // MARK: - PhotoLibraryView
    var onCloseButtonTap: (() -> ())?
    
    var onContinueButtonTap: (() -> ())?
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    var onTitleTap: (() -> ())?
    var onDimViewTap: (() -> ())?
    
    func setContinueButtonTitle(_ title: String) {
        topRightContinueButton.setTitle(title, for: .normal)
        topRightContinueButton.accessibilityValue = title
        topRightContinueButton.size = CGSize(width: topRightContinueButton.sizeThatFits().width, height: continueButtonHeight)
        titleView.setNeedsLayout()
        
        bottomContinueButton.setTitle(title, for: .normal)
        bottomContinueButton.accessibilityValue = title
    }
    
    func setContinueButtonPlacement(_ placement: MediaPickerContinueButtonPlacement) {
        continueButtonPlacement = placement
    }
    
    func setCameraViewData(_ viewData: PhotoLibraryCameraViewData?) {
        
        cameraViewData = viewData
        
        UIView.performWithoutAnimation {
            // `collectionView.reloadSections(IndexSet(0..<1))` freezes app completely, don't use it
            collectionView.reloadData()
        }
    }
    
    func setItems(_ items: [PhotoLibraryItemCellData], scrollToTop: Bool, completion: (() -> ())?) {
        
        if scrollToTop {
            coverCollectionViewWithItsSnapshot()
        }
        
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
                        if scrollToTop {
                            collectionView.scrollToTop()
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
    
    func deselectCell(with imageSource: ImageSource) {
        if let indexPath = dataSource.indexPath(where: { $0.image == imageSource }) {
            deselectCell(at: indexPath)
        }
    }
    
    func deselectAndAdjustAllCells() {
        collectionView.indexPathsForSelectedItems?.forEach { deselectCell(at: $0) }
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
    
    func setHeaderVisible(_ visible: Bool) {
        guard layout.hasHeader != visible else {
            return 
        }
        collectionView.performBatchUpdates { [weak self] in
            self?.layout.hasHeader = visible
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
    
    private var theme: PhotoLibraryV2UITheme?
    
    private func configureDataSource() {
        dataSource.additionalCellConfiguration = { [weak self] cell, data, collectionView, indexPath in
            self?.configureCell(cell, wihData: data, inCollectionView: collectionView, atIndexPath: indexPath)
        }
        
        dataSource.configureHeader = { [weak self] view in
            guard let view = view as? PhotoLibraryCameraView else {
                return
            }
            
            view.setCameraIcon(self?.theme?.cameraIcon)
            
            view.onTap = self?.cameraViewData?.onTap
            
            if let parameters = self?.cameraViewData?.parameters {
                view.setOutputParameters(parameters)
            }
        }
    }
    
    private func setUpAccessibilityIdentifiers() {
        accessibilityIdentifier = AccessibilityId.photoLibrary.rawValue
        
        closeButton.accessibilityIdentifier = AccessibilityId.discardLibraryButton.rawValue
        topRightContinueButton.accessibilityIdentifier = AccessibilityId.confirmLibraryButton.rawValue
        bottomContinueButton.accessibilityIdentifier = AccessibilityId.confirmLibraryButton.rawValue
    }
    
    private func setUpButtons() {
        closeButton.size = closeButtonSize
        closeButton.addTarget(
            self,
            action: #selector(onCloseButtonTap(_:)),
            for: .touchUpInside
        )
        
        topRightContinueButton.size = CGSize(
            width: continueButtonHeight,
            height: topRightContinueButton.sizeThatFits().width
        )
        
        topRightContinueButton.contentEdgeInsets = continueButtonContentInsets
        topRightContinueButton.addTarget(
            self,
            action: #selector(onContinueButtonTap(_:)),
            for: .touchUpInside
        )
        
        bottomContinueButton.layer.cornerRadius = 5
        bottomContinueButton.titleEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 14, right: 16)
        bottomContinueButton.addTarget(
            self,
            action: #selector(onContinueButtonTap(_:)),
            for: .touchUpInside
        )
    }
    
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
        if let headerReuseIdentifier = dataSource.headerReuseIdentifier {
            collectionView.register(
                PhotoLibraryCameraView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: headerReuseIdentifier
            )
        }
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
    
    private func deselectCell(at indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        onDeselectItem(at: indexPath)
    }
    
    @objc private func onCloseButtonTap(_: UIButton) {
        onCloseButtonTap?()
    }
    
    @objc private func onContinueButtonTap(_: UIButton) {
        onContinueButtonTap?()
    }
}

private final class FadeView: UIView {
    
    let gradientHeight: CGFloat
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var frame: CGRect {
        didSet {
            guard bounds.height > 0 else { return }
            
            (layer as? CAGradientLayer)?.endPoint = CGPoint(
                x: 0.5,
                y: min(gradientHeight / bounds.height, 1)
            )
        }
    }
    
    init(gradientHeight: CGFloat) {
        self.gradientHeight = gradientHeight
        
        super.init(frame: .zero)
        
        (layer as? CAGradientLayer)?.colors = [
            UIColor(white: 1, alpha: 0).cgColor,
            UIColor(white: 1, alpha: 1).cgColor
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
