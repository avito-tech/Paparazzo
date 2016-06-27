import UIKit

final class PhotoPreviewView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let collectionView: UICollectionView
    private let dataSource: MediaRibbonDataSource
    
    // MARK: - Constants
    
    private var cameraView: UIView?
    
    private let photoCellReuseId = "PhotoCell"
    private let cameraCellReuseId = "CameraCell"
    
    // MARK: - Init
    
    init(dataSource: MediaRibbonDataSource) {
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.pagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.registerClass(MediaRibbonCell.self, forCellWithReuseIdentifier: photoCellReuseId)
        collectionView.registerClass(BlaBlaCameraCell.self, forCellWithReuseIdentifier: cameraCellReuseId)
        
        self.dataSource = dataSource
        
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
        if let indexPath = dataSource.indexPathForCameraItem() {
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: animated)
        }
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
            return UICollectionViewCell()   // TODO
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

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
