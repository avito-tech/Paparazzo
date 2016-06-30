import UIKit

final class PhotoPreviewView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var onSwipeToItem: (MediaPickerItem -> ())?
    var onSwipeToCamera: (() -> ())?
    var onSwipeToCameraProgressChange: (CGFloat -> ())?
    
    private let collectionView: UICollectionView
    private let dataSource = MediaRibbonDataSource()
    
    // MARK: - Constants
    
    private var cameraView: UIView?
    
    private let photoCellReuseId = "PhotoCell"
    private let cameraCellReuseId = "CameraCell"
    
    // MARK: - Init
    
    init() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.pagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.registerClass(PhotoPreviewCell.self, forCellWithReuseIdentifier: photoCellReuseId)
        collectionView.registerClass(BlaBlaCameraCell.self, forCellWithReuseIdentifier: cameraCellReuseId)
        print("preview collection view: \(collectionView)")
        
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
    
    func scrollToCamera(animated animated: Bool = false) {
        let indexPath = dataSource.indexPathForCameraItem()
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
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
    
    func removeItem(item: MediaPickerItem, animated: Bool) {
        collectionView.deleteItems(animated: animated) { [weak self] in
            let removedIndexPath = self?.dataSource.removeItem(item)
            return removedIndexPath.flatMap { [$0] }
        }
    }
    
    func setCameraVisible(visible: Bool) {
        
        if dataSource.cameraCellVisible != visible {
            
            if visible {
                
                dataSource.cameraCellVisible = visible
                addCollectionViewItemsAtIndexPaths([dataSource.indexPathForCameraItem()])
            
            } else {
                
                collectionView.deleteItems(animated: false) { [weak self] in
                    self?.dataSource.cameraCellVisible = visible
                    return (self?.dataSource.indexPathForCameraItem()).flatMap { [$0] }
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfItems
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch dataSource[indexPath] {
        
        case .Camera:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cameraCellReuseId, forIndexPath: indexPath)
            
            if let cell = cell as? BlaBlaCameraCell {
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
        onSwipeToCameraProgressChange?(progress)
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
        
        let currentPage = max(0, Int(floor(collectionView.contentOffset.x / collectionView.width)))
        let indexPath = NSIndexPath(forItem: currentPage, inSection: 0)
        
        switch dataSource[indexPath] {
        case .Photo(let item):
            onSwipeToItem?(item)
        case .Camera:
            onSwipeToCamera?()
        }
    }
    
    private func addCollectionViewItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        
        let currentPage = floor(collectionView.contentOffset.x / collectionView.width)
        let nextPage = currentPage + CGFloat(indexPaths.filter({ $0.item <= Int(currentPage) }).count)
        let indexPath = NSIndexPath(forItem: Int(nextPage), inSection: 0)
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
    }
}

// TODO: придумать нормальное название, вынести в отдельный файл
private final class BlaBlaCameraCell: UICollectionViewCell {
    
    var cameraView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let cameraView = cameraView {
                addSubview(cameraView)
            }
        }
    }
    
    private override func layoutSubviews() {
        super.layoutSubviews()
        cameraView?.frame = contentView.bounds
    }
}
