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
    
    func setCameraView(view: UIView) {
        cameraView = view
    }
    
    func scrollToCamera(animated: Bool = false) {
        let indexPath = dataSource.indexPathForCameraItem()
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    func scrollToMediaItem(item: MediaPickerItem, animated: Bool = false) {
        if let indexPath = dataSource.indexPathForItem(item) {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
        }
    }
    
    func addItems(items: [MediaPickerItem]) {
        let insertedIndexPaths = dataSource.addItems(items)
        addCollectionViewItemsAtIndexPaths(insertedIndexPaths)
    }
    
    func updateItem(item: MediaPickerItem) {
        if let indexPath = dataSource.updateItem(item) {
            collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }
    
    func removeItem(item: MediaPickerItem, animated: Bool) {
        collectionView.deleteItems(animated: animated) { [weak self] in
            let removedIndexPath = self?.dataSource.removeItem(item)
            return removedIndexPath.flatMap { [$0] }
        }
    }
    
    func setCameraVisible(visible: Bool) {
        
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
        
        case .Camera:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cameraCellReuseId, forIndexPath: indexPath)
            
            if let cell = cell as? MainCameraCell {
                cell.cameraView = cameraView
            }
            
            return cell
        
        case .Photo(let mediaPickerItem):
            return photoCell(forIndexPath: indexPath, inCollectionView: collectionView, withItem: mediaPickerItem)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: - UIScrollViewDelegate
    
    private var lastOffset: CGFloat?
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        guard let lastOffset = lastOffset else {
            self.lastOffset = scrollView.contentOffset.x
            return
        }
        
        let offset = scrollView.contentOffset.x
        let pageWidth = scrollView.width
        let direction = offset - lastOffset
        let numberOfPages = ceil(scrollView.contentSize.width / pageWidth)
        
        let penultimatePageOffsetX = pageWidth * (numberOfPages - 2)
        let isLastPageVisible = (offset >= penultimatePageOffsetX)
        
        let progress = min(1, (offset - penultimatePageOffsetX) / pageWidth)
        
        if dataSource.cameraCellVisible {
            onSwipeToCameraProgressChange?(progress)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            onSwipeFinished()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        onSwipeFinished()
    }
    
    // MARK: - Private
    
    private var currentPage: Int {
        if collectionView.width > 0 {
            return max(0, Int(floor(collectionView.contentOffset.x / collectionView.width)))
        } else {
            return 0
        }
    }
    
    private func photoCell(
        forIndexPath indexPath: NSIndexPath,
        inCollectionView collectionView: UICollectionView,
        withItem mediaPickerItem: MediaPickerItem
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            photoCellReuseId,
            forIndexPath: indexPath
        )
        
        if let cell = cell as? PhotoPreviewCell {
            cell.customizeWithItem(mediaPickerItem)
        }
        
        return cell
    }
    
    private func onSwipeFinished() {
        
        let indexPath = NSIndexPath(forItem: currentPage, inSection: 0)
        
        switch dataSource[indexPath] {
        case .Photo(let item):
            onSwipeToItem?(item)
        case .Camera:
            onSwipeToCamera?()
        }
    }
    
    private func addCollectionViewItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        
        // После добавления новых ячеек фокус должен остаться на той ячейке, на которой он был до этого.
        // Сдвинуться он может только если добавятся ячейки перед текущей. Поэтому вычисляет новый indexPath
        // текущей ячейки, прибавляя к ее текущему индексу количество элементов, добавленных перед ней.
        
        let indexesOfInsertedPages = indexPaths.map { $0.row }
        
        let indexPath = NSIndexPath(
            forItem: indexOfPage(currentPage, afterInsertingPagesAtIndexes: indexesOfInsertedPages),
            inSection: 0
        )

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
    }
    
    private func indexOfPage(initialIndex: Int, afterInsertingPagesAtIndexes insertedIndexes: [Int]) -> Int {
        
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
