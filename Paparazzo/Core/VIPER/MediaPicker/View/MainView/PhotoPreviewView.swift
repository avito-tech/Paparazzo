import UIKit

final class PhotoPreviewView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var onSwipeToItem: ((MediaPickerItem) -> ())?
    var onSwipeToCamera: (() -> ())?
    var onSwipeToCameraProgressChange: ((CGFloat) -> ())?
    
    private let collectionView: UICollectionView
    private let dataSource = MediaRibbonDataSource()
    
    // MARK: - Constants
    
    private var cameraView: UIView?
    
    private let photoCellReuseId = "PhotoCell"
    private let cameraCellReuseId = "CameraCell"
    
    // MARK: - Init
    
    init() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: photoCellReuseId)
        collectionView.register(MainCameraCell.self, forCellWithReuseIdentifier: cameraCellReuseId)
        
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
    
    // MARK: - PhotoPreviewView
    
    func setCameraView(_ view: UIView) {
        cameraView = view
    }
    
    func scrollToCamera(animated: Bool = false) {
        let indexPath = dataSource.indexPathForCameraItem()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    func scrollToMediaItem(_ item: MediaPickerItem, animated: Bool = false) {
        if let indexPath = dataSource.indexPathForItem(item) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        }
    }
    
    func addItems(_ items: [MediaPickerItem]) {
        let insertedIndexPaths = dataSource.addItems(items)
        addCollectionViewItemsAtIndexPaths(insertedIndexPaths)
    }
    
    func updateItem(_ item: MediaPickerItem) {
        if let indexPath = dataSource.updateItem(item) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func removeItem(_ item: MediaPickerItem, animated: Bool) {
        collectionView.deleteItems(animated: animated) { [weak self] in
            let removedIndexPath = self?.dataSource.removeItem(item)
            return removedIndexPath.flatMap { [$0] }
        }
    }
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else { return }
        
        collectionView.performBatchUpdates() { [weak self] in
            self?.dataSource.moveItem(
                from: sourceIndex,
                to: destinationIndex
            )
            
            self?.collectionView.moveItem(
                at: IndexPath(item: sourceIndex, section: 0),
                to: IndexPath(item: destinationIndex, section: 0)
            )
        }
    }
    
    func setCameraVisible(_ visible: Bool) {
        
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
    
    func reloadCamera() {
        if dataSource.cameraCellVisible {
            collectionView.reloadItems(at: [dataSource.indexPathForCameraItem()])
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch dataSource[indexPath] {
        
        case .camera:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cameraCellReuseId, for: indexPath)
            
            if let cell = cell as? MainCameraCell {
                cell.cameraView = cameraView
            }
            
            return cell
        
        case .photo(let mediaPickerItem):
            return photoCell(forIndexPath: indexPath, inCollectionView: collectionView, withItem: mediaPickerItem)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: - UIScrollViewDelegate
    
    private var lastOffset: CGFloat?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard lastOffset != nil else {
            self.lastOffset = scrollView.contentOffset.x
            return
        }
        
        let offset = scrollView.contentOffset.x
        let pageWidth = scrollView.width
        let numberOfPages = ceil(scrollView.contentSize.width / pageWidth)
        
        let penultimatePageOffsetX = pageWidth * (numberOfPages - 2)
        
        let progress = min(1, (offset - penultimatePageOffsetX) / pageWidth)
        
        if dataSource.cameraCellVisible {
            onSwipeToCameraProgressChange?(progress)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            onSwipeFinished()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onSwipeFinished()
    }
    
    // MARK: - Private
    
    private var currentPage: Int {
        if collectionView.width > 0 {
            // paging follows 4/5 rule so it uses round() function.
            // |  0  |  1  |  2  |
            // ------offset:------
            // |  0  |     |     | // 0.00 -> 0
            // ||  0  |    |     | // 0.16 -> 0
            // | |  0  |   |     | // 0.33 -> 0
            // |  |  ?  |  |     | // 0.50 -> doesn't really matter
            // |   |  1  | |     | // 0.66 -> 1
            // |    |  1  ||     | // 0.83 -> 1
            // |     |  1  |     | // 1.00 -> 1
            //
            let pageRatio: CGFloat = collectionView.contentOffset.x / collectionView.width
            let maxPage = dataSource.numberOfItems - 1
            return max(0, min(maxPage, Int(round(pageRatio))))
        } else {
            return 0
        }
    }
    
    private func photoCell(
        forIndexPath indexPath: IndexPath,
        inCollectionView collectionView: UICollectionView,
        withItem mediaPickerItem: MediaPickerItem
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: photoCellReuseId,
            for: indexPath
        )
        
        if let cell = cell as? PhotoPreviewCell {
            cell.customizeWithItem(mediaPickerItem)
        }
        
        return cell
    }
    
    private func onSwipeFinished() {
        
        let indexPath = IndexPath(item: currentPage, section: 0)
        
        switch dataSource[indexPath] {
        case .photo(let item):
            onSwipeToItem?(item)
        case .camera:
            onSwipeToCamera?()
        }
    }
    
    private func addCollectionViewItemsAtIndexPaths(_ indexPaths: [IndexPath]) {
        
        // После добавления новых ячеек фокус должен остаться на той ячейке, на которой он был до этого.
        // Сдвинуться он может только если добавятся ячейки перед текущей. Поэтому вычисляет новый indexPath
        // текущей ячейки, прибавляя к ее текущему индексу количество элементов, добавленных перед ней.
        
        let indexesOfInsertedPages = indexPaths.map { $0.row }
        
        let indexPath = IndexPath(
            item: indexOfPage(currentPage, afterInsertingPagesAtIndexes: indexesOfInsertedPages),
            section: 0
        )

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: indexPath, at: [], animated: false)
    }
    
    private func indexOfPage(_ initialIndex: Int, afterInsertingPagesAtIndexes insertedIndexes: [Int]) -> Int {
        
        let sortedIndexes = insertedIndexes.sorted(by: <)
        var targetIndex = initialIndex
        
        for index in sortedIndexes {
            if index <= targetIndex {
                targetIndex += 1
            } else {
                break
            }
        }
        
        return max(0, min(dataSource.numberOfItems - 1, targetIndex))
    }
}
