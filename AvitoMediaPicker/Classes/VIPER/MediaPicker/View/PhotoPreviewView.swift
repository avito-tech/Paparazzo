import UIKit

final class PhotoPreviewView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let dataSource = MediaRibbonDataSource()
    
    private let collectionView: UICollectionView
    
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
        collectionView.alwaysBounceHorizontal = true
        collectionView.pagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.registerClass(MediaRibbonCell.self, forCellWithReuseIdentifier: photoCellReuseId)
        collectionView.registerClass(BlaBlaCameraCell.self, forCellWithReuseIdentifier: cameraCellReuseId)
        
        super.init(frame: .zero)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setUpDataSourceHandlers()
        
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
    
    // MARK: - Private
    
    private func setUpDataSourceHandlers() {
        
        dataSource.onItemsAdd = { [weak collectionView] indexPaths, mutateData in
            collectionView?.performNonAnimatedBatchUpdates {
                collectionView?.insertItemsAtIndexPaths(indexPaths)
                mutateData()
            }
        }
        
        dataSource.onItemsRemove = { [weak collectionView] indexPaths, mutateData in
            collectionView?.performNonAnimatedBatchUpdates {
                collectionView?.deleteItemsAtIndexPaths(indexPaths)
                mutateData()
            }
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
        
        if let cell = cell as? MediaRibbonCell {
            cell.customizeWithItem(mediaPickerItem)
        }
        
        return cell
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
