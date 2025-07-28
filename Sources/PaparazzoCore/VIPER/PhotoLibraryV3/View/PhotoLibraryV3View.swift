import AVFoundation
import ImageSource
import UIKit

final class PhotoLibraryV3View: UIView, ThemeConfigurable {
    
    typealias ThemeType = PhotoLibraryV3UITheme & NewCameraUITheme
    
    private enum AlbumsListState {
        case collapsed
        case expanded
    }
    
    // MARK: Privete Properties
    
    private var theme: PhotoLibraryV3UITheme?
    
    private var albumsListState: AlbumsListState = .collapsed
    
    private var cameraViewData: PhotoLibraryV3CameraViewData?
    
    private var continueButtonPlacement = MediaPickerContinueButtonPlacement.topRight {
        didSet {
            switch continueButtonPlacement {
            case .topRight:
                bottomContinueButton.removeFromSuperview()
                insertSubview(topRightContinueButton, belowSubview: progressIndicator)
            case .bottom:
                topRightContinueButton.removeFromSuperview()
                insertSubview(bottomContinueButton, belowSubview: albumsTableView)
            }
        }
    }
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryV3ItemCell>(
        cellReuseIdentifier: "PhotoLibraryV3ItemCell",
        headerReuseIdentifier: "PhotoLibraryV3CameraView"
    )
    
    // MARK: Properties
    
    var canSelectMoreItems = false
    
    var dimsUnselectedItems = false {
        didSet {
            adjustDimmingForVisibleCells()
        }
    }
    
    var cameraView: PhotoLibraryV3CameraView? {
        return collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? PhotoLibraryV3CameraView
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return cameraView?.cameraOutputLayer
    }
    
    // MARK: Handler
    
    var onCloseButtonTap: (() -> ())?
    
    var onContinueButtonTap: (() -> ())?
    
    var onAccessDeniedButtonTap: (() -> ())? {
        get { return accessDeniedView.onButtonTap }
        set { accessDeniedView.onButtonTap = newValue }
    }
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { return selectedPhotosBarView.onLastPhotoThumbnailTap }
        set { selectedPhotosBarView.onLastPhotoThumbnailTap = newValue }
    }
    
    var onTitleTap: (() -> ())?
    var onDimViewTap: (() -> ())?
    
    // MARK: UI elements
    
    private let layout = PhotoLibraryV3Layout()
    private var collectionView: UICollectionView
    private var collectionSnapshotView: UIView?
    private let titleView = PhotoLibraryV3TitleView()
    private let accessDeniedView = AccessDeniedView()
    private let progressIndicator = UIActivityIndicatorView(style: .whiteLarge)
    private let dimView = UIView()
    private let albumsTableView = PhotoLibraryAlbumsTableView()
    private let placeholderView = UILabel()
    private let closeButton = UIButton()
    private let topRightContinueButton = ButtonWithActivity(shouldResizeToFitActivity: true)
    private let bottomContinueButton = ButtonWithActivity(activityStyle: .white)
    
    private lazy var selectedPhotosBarView: SelectedPhotosV3BarView = {
        let view = SelectedPhotosV3BarView()
        view.isHidden = true
        view.accessibilityIdentifier = "selectedPhotosBarView"
        view.layer.cornerRadius = 28
        return view
    }()
    
    // MARK: Specs
    
    private let closeButtonSize = CGSize(width: 38, height: 38)
    private let continueButtonHeight = CGFloat(38)
    private let continueButtonContentInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    // MARK: Init
    
    init() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        
        configureDataSource()
        setUpCollectionView()
        
        backgroundColor = .white
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTitleViewTap(_:))))
        titleView.accessibilityIdentifier = "titleView"
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        dimView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onDimViewTap(_:)))
        )
        
        accessDeniedView.isHidden = true
        placeholderView.isHidden = true
        
        selectedPhotosBarView.onButtonTap = { [weak self] in
            self?.onContinueButtonTap?()
        }
        
        setUpButtons()
        
        addSubview(collectionView)
        addSubview(placeholderView)
        addSubview(accessDeniedView)
        addSubview(dimView)
        addSubview(selectedPhotosBarView)
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
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.frame = CGRect(
            x: 8,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: closeButton.width,
            height: closeButton.height
        )
        
        layOutTopRightContinueButton()
        
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
        
        let collectionViewTop = max(closeButton.bottom, titleView.bottom)
        collectionView.layout(
            left: bounds.left,
            right: bounds.right,
            top: collectionViewTop,
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
        
        selectedPhotosBarView.size = selectedPhotosBarView.sizeThatFits(
            CGSize(width: bounds.width - 32, height: .greatestFiniteMagnitude)
        )
        
        selectedPhotosBarView.center = CGPoint(
            x: bounds.centerX,
            y: bounds.bottom - max(16, paparazzoSafeAreaInsets.bottom) - selectedPhotosBarView.size.height / 2
        )
    }
    
    // MARK: - ThemeConfigurable
    
    func setTheme(_ theme: ThemeType) {
        self.theme = theme
        
        collectionView.backgroundColor = theme.photoLibraryCollectionBackgroundColor
        
        titleView.setLabelFont(theme.photoLibraryTitleFont)
        titleView.setIcon(theme.photoLibraryAlbumsDisclosureIcon)
        titleView.backgroundColor = theme.photoLibraryCollectionBackgroundColor
        titleView.setTitleColor(theme.photoLibraryTitleColor)
        titleView.setIconColor(theme.photoLibraryAlbumsDisclosureIconColor)
        
        accessDeniedView.setTheme(theme)
        
        closeButton.setImage(theme.closeIcon, for: .normal)
        closeButton.tintColor = theme.closeIconColor
        
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
        albumsTableView.setCellBackgroundColor(theme.photoLibraryAlbumsTableViewCellBackgroundColor)
        albumsTableView.setTableViewBackgroundColor(theme.photoLibraryAlbumsTableViewBackgroundColor)
        albumsTableView.setTopSeparatorColor(theme.photoLibraryAlbumsTableTopSeparatorColor)
        albumsTableView.setCellDefaultLabelColor(theme.photoLibraryAlbumsCellDefaultLabelColor)
        albumsTableView.setCellSelectedLabelColor(theme.photoLibraryAlbumsCellSelectedLabelColor)
        
        placeholderView.font = theme.photoLibraryPlaceholderFont
        placeholderView.textColor = theme.photoLibraryPlaceholderColor
        
        selectedPhotosBarView.setTheme(theme)
    }
    
    func previewFrame(forBounds bounds: CGRect) -> CGRect {
        let layout = collectionView.collectionViewLayout as? PhotoLibraryV3Layout
        let indexPath = IndexPath(item: 0, section: 0)
        
        if let frame = layout?.frameForHeader(at: indexPath) {
            return convert(frame, from: collectionView)
        }
        
        return .zero
    }
    
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        cameraView?.setPreviewLayer(previewLayer)
    }
    
    func setContinueButtonTitle(_ title: String) {
        topRightContinueButton.setTitle(title, for: .normal)
        topRightContinueButton.accessibilityValue = title
        topRightContinueButton.size = CGSize(
            width: topRightContinueButton.sizeThatFits().width,
            height: continueButtonHeight
        )
        titleView.setNeedsLayout()
        
        bottomContinueButton.setTitle(title, for: .normal)
        bottomContinueButton.accessibilityValue = title
    }
    
    func setContinueButtonVisible(_ isVisible: Bool) {
        topRightContinueButton.isHidden = !isVisible
        bottomContinueButton.isHidden = !isVisible
    }
    
    func setContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        selectedPhotosBarView.setContinueButtonStyle(style)
        bottomContinueButton.style = style
        setTopRightContinueButtonStyle(style)
    }
    
    func setContinueButtonPlacement(_ placement: MediaPickerContinueButtonPlacement) {
        continueButtonPlacement = placement
    }
    
    func setCameraViewData(_ viewData: PhotoLibraryV3CameraViewData?) {
        cameraViewData = viewData
        
        if let cameraView = cameraView {
            dataSource.configureHeader?(cameraView)
        }
    }
    
    func setItems(_ items: [PhotoLibraryV3ItemCellData], scrollToTop: Bool, completion: (() -> ())?) {
        
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
                        self.selectCollectionViewCellsAccordingToDataSource()
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
    
    func applyChanges(_ changes: PhotoLibraryV3ViewChanges, completion: @convention(block) @escaping () -> ()) {
        ObjCExceptionCatcher.tryClosure(
            tryClosure: { [collectionView, weak self] in
                collectionView.performBatchUpdates(animated: true, updates: {
                    guard let self = self else { return }

                    let toIndexPath = { (index: Int) in
                        IndexPath(item: index, section: 0)
                    }

                    // Order is important!
                    // 1. Removing items
                    self.removeItems(changes: changes, toIndexPath: toIndexPath, collectionView: self.collectionView, dataSource: self.dataSource)

                    // 2. Inserting items
                    self.insertItems(changes: changes, toIndexPath: toIndexPath, collectionView: self.collectionView, dataSource: self.dataSource)

                    // 3. Updating items
                    self.updateItems(changes: changes, toIndexPath: toIndexPath, collectionView: self.collectionView, dataSource: self.dataSource)

                    // 4. Moving items
                    self.moveItems(changes: changes, toIndexPath: toIndexPath, collectionView: self.collectionView, dataSource: self.dataSource)

                    }, completion: { [weak self] _ in
                        self?.selectCollectionViewCellsAccordingToDataSource()
                        completion()
                    }
                )
            },
            catchClosure: { _ in
                self.recreateCollectionView()
                completion()
            }
        )
    }
    
    func deselectCell(with imageSource: ImageSource) -> Bool {
        if let indexPath = dataSource.indexPath(where: { $0.image == imageSource }) {
            deselectCell(at: indexPath)
            return true
        } else {
            return false
        }
    }
    
    func deselectAndAdjustAllCells() {
        collectionView.indexPathsForSelectedItems?.forEach { deselectCell(at: $0) }
    }
    
    func reloadSelectedItems() {
        guard let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems else { return }
        
        collectionView.reloadItems(at: indexPathsForSelectedItems)
        
        // Restore selection after reload
        for indexPath in indexPathsForSelectedItems {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
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
    
    func setSelectedPhotosBarState(_ state: SelectedPhotosBarState) {
        switch state {
        case .hidden:
            selectedPhotosBarView.setHidden(true, animated: true)
        case .placeholder:
            selectedPhotosBarView.setPlaceholderHidden(false)
        case .visible(let data):
            selectedPhotosBarView.setPlaceholderHidden(true)
            selectedPhotosBarView.setHidden(false, animated: true)
            selectedPhotosBarView.label.text = data.countString
            selectedPhotosBarView.setLastImage(data.lastPhoto)
        }
    }
    
    func setDoneButtonTitle(_ title: String) {
        selectedPhotosBarView.setDoneButtonTitle(title)
    }
    
    func setPlaceholderText(_ text: String) {
        selectedPhotosBarView.setPlaceholderText(text)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoLibraryV3View: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath)
    {
        adjustDimmingForCell(cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cellData = dataSource.item(at: indexPath)
        let shouldSelect = canSelectMoreItems && cellData.previewAvailable
        
        if shouldSelect {
            cellData.onSelectionPrepare?()
        }
        
        return shouldSelect
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        dataSource.mutateItem(at: indexPath) { (cellData: inout PhotoLibraryV3ItemCellData) in
            cellData.selected = true
        }
        dataSource.item(at: indexPath).onSelect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoLibraryV3ItemCell {
            let data = dataSource.item(at: indexPath)
            cell.setSelectionIndex(data.getSelectionIndex?())
            cell.adjustAppearanceForSelected(true, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        onDeselectItem(at: indexPath)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoLibraryV3ItemCell {
            let data = dataSource.item(at: indexPath)
            cell.setSelectionIndex(data.getSelectionIndex?())
            cell.adjustAppearanceForSelected(false, animated: true)
        }
    }
}

// MARK: - Private methods

private extension PhotoLibraryV3View {
    private func configureDataSource() {
        dataSource.additionalCellConfiguration = { [weak self] cell, data, collectionView, indexPath in
            self?.configureCell(cell, wihData: data, inCollectionView: collectionView, atIndexPath: indexPath)
        }
        
        dataSource.configureHeader = { [weak self] view in
            guard let view = view as? PhotoLibraryV3CameraView else {
                return
            }
            
            view.setCameraIcon(self?.theme?.cameraIcon)
            view.setCameraIconColor(self?.theme?.cameraIconColor)
            
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
            PhotoLibraryV3ItemCell.self,
            forCellWithReuseIdentifier: dataSource.cellReuseIdentifier
        )
        
        if let headerReuseIdentifier = dataSource.headerReuseIdentifier {
            collectionView.register(
                PhotoLibraryV3CameraView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: headerReuseIdentifier
            )
        }
    }
    
    private func setTopRightContinueButtonStyle(_ style: MediaPickerContinueButtonStyle) {
        guard topRightContinueButton.style != style else { return }
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.topRightContinueButton.style = style
                self.layOutTopRightContinueButton()
            }
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
        insertSubview(collectionView, belowSubview: placeholderView)
        
        // Display a collection view snapshot to improve user experience
        if let snapshot = collectionViewSnapshot {
            collectionView.superview?.addSubview(snapshot)
        }
        
        // Reload the data in a non-animated fashion
        reloadDataPreservingSelection()
        
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
    
    private func reloadDataPreservingSelection() {
        collectionView.reloadData()
        selectCollectionViewCellsAccordingToDataSource()
    }
    
    private func selectCollectionViewCellsAccordingToDataSource() {
        // TODO: Сейчас тут замедляется UI на огромных галереях из-за итерирования по всем айтемам
        for indexPath in dataSource.indexPaths(where: { $0.selected }) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
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
        _ cell: PhotoLibraryV3ItemCell,
        wihData data: PhotoLibraryV3ItemCellData,
        inCollectionView collectionView: UICollectionView,
        atIndexPath indexPath: IndexPath)
    {
        cell.backgroundColor = theme?.photoCellBackgroundColor
        cell.selectedBorderColor = theme?.photoLibraryItemSelectionColor.cgColor
        cell.selectionIndexFont = theme?.librarySelectionIndexFont
        cell.setBadgeTextColor(theme?.libraryItemBadgeTextColor)
        cell.setBadgeBackgroundColor(theme?.libraryItemBadgeBackgroundColor)
        
        cell.setCloudIcon(theme?.iCloudIcon)
        
        cell.onImageSetFromSource = { [weak self] in
            self?.dataSource.mutateItem(data, at: indexPath) { (data: inout PhotoLibraryV3ItemCellData) in
                data.previewAvailable = true
            }
        }
        
        cell.setAccessibilityId(index: indexPath.row)
        
        cell.setSelectionIndex(data.getSelectionIndex?())
        cell.adjustAppearanceForSelected(data.selected, animated: false)
    }
    
    private func onDeselectItem(at indexPath: IndexPath) {
        dataSource.mutateItem(at: indexPath) { (cellData: inout PhotoLibraryV3ItemCellData) in
            cellData.selected = false
        }
        dataSource.item(at: indexPath).onDeselect?()
        
        adjustDimmingForCellAtIndexPath(indexPath)
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
    
    private func layOutTopRightContinueButton() {
        let width = topRightContinueButton.sizeThatFits().width
        
        topRightContinueButton.frame = CGRect(
            x: bounds.right - 8 - width,
            y: max(8, paparazzoSafeAreaInsets.top),
            width: width,
            height: continueButtonHeight
        )
    }
    
    private func deselectCell(at indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        onDeselectItem(at: indexPath)
        
        // TODO: убрать дублирование
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoLibraryV3ItemCell {
            let data = dataSource.item(at: indexPath)
            cell.setSelectionIndex(data.getSelectionIndex?())
            cell.adjustAppearanceForSelected(false, animated: true)
        }
    }
    
    private func removeItems(
        changes: PhotoLibraryV3ViewChanges,
        toIndexPath: (Int) -> IndexPath,
        collectionView: UICollectionView,
        dataSource: CollectionViewDataSource<PhotoLibraryV3ItemCell>
    ) {
        let indexPathsToDelete = changes.removedIndexes.map(toIndexPath)

        if indexPathsToDelete.count > 0 {
            collectionView.deleteItems(at: indexPathsToDelete)
            dataSource.deleteItems(at: indexPathsToDelete)
        }
    }
    
    private func insertItems(
        changes: PhotoLibraryV3ViewChanges,
        toIndexPath: (Int) -> IndexPath,
        collectionView: UICollectionView,
        dataSource: CollectionViewDataSource<PhotoLibraryV3ItemCell>
    ) {
        let indexPathsToInsert = changes.insertedItems.map { toIndexPath($0.index) }

        if indexPathsToInsert.count > 0 {
            collectionView.insertItems(at: indexPathsToInsert)
            dataSource.insertItems(changes.insertedItems.map { item in
                (item: item.cellData, indexPath: toIndexPath(item.index))
            })
        }
    }
    
    private func updateItems(
        changes: PhotoLibraryV3ViewChanges,
        toIndexPath: (Int) -> IndexPath,
        collectionView: UICollectionView,
        dataSource: CollectionViewDataSource<PhotoLibraryV3ItemCell>
    ) {
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
    }
    
    private func moveItems(
        changes: PhotoLibraryV3ViewChanges,
        toIndexPath: (Int) -> IndexPath,
        collectionView: UICollectionView,
        dataSource: CollectionViewDataSource<PhotoLibraryV3ItemCell>
    ) {
        changes.movedIndexes.forEach { from, to in
            let sourceIndexPath = toIndexPath(from)
            let targetIndexPath = toIndexPath(to)

            collectionView.moveItem(at: sourceIndexPath, to: targetIndexPath)
            dataSource.moveItem(at: sourceIndexPath, to: targetIndexPath)
        }
    }
    
    @objc private func onTitleViewTap(_: UITapGestureRecognizer) {
        onTitleTap?()
    }
    
    @objc private func onDimViewTap(_: UITapGestureRecognizer) {
        onDimViewTap?()
    }
    
    @objc private func onCloseButtonTap(_: UIButton) {
        onCloseButtonTap?()
    }
    
    @objc private func onContinueButtonTap(_: UIButton) {
        onContinueButtonTap?()
    }
}
