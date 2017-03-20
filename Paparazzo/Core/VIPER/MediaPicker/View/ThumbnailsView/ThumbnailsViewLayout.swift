import UIKit

final class ThumbnailsViewLayout: UICollectionViewFlowLayout {
    
    var itemsTransform = CGAffineTransform.identity
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    private var originalIndexPath: IndexPath?
    private var draggingIndexPath: IndexPath?
    private var draggingView: UIView?
    private var dragOffset = CGPoint.zero
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        installGestureRecognizer()
    }
    
    private func installGestureRecognizer() {
        if longPressGestureRecognizer == nil {
            longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ThumbnailsViewLayout.handleLongPress(longPress:)))
            longPressGestureRecognizer?.minimumPressDuration = 0.2
            collectionView?.addGestureRecognizer(longPressGestureRecognizer!)
        }
    }
    
    // MARK: - UICollectionViewLayout
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        adjustAttributes(attributes)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        attributes?.forEach { attributes in
            
            let delegate = collectionView?.delegate as? MediaRibbonLayoutDelegate
            let shouldApplyTransform = delegate?.shouldApplyTransformToItemAtIndexPath(attributes.indexPath) ?? true
            
            attributes.transform = shouldApplyTransform ? itemsTransform : .identity
        }
        
        return attributes
    }
    
    // MARK: - Private
    
    private func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes?) {
        attributes?.transform = itemsTransform
    }
    
    @objc fileprivate func handleLongPress(longPress: UILongPressGestureRecognizer) {
        let location = longPress.location(in: collectionView)
        switch longPress.state {
        case .began: startDragAtLocation(location: location)
        case .changed: updateDragAtLocation(location: location)
        case .ended: endDragAtLocation(location: location)
        default:
            break
        }
    }
    
    private func startDragAtLocation(location: CGPoint) {
        guard let cv = collectionView else { return }
        guard let indexPath = cv.indexPathForItem(at: location) else { return }
        guard let cell = cv.cellForItem(at: indexPath) else { return }
        guard let delegate = collectionView?.delegate as? MediaRibbonLayoutDelegate else { return }
        guard delegate.canMoveTo(indexPath) != false else { return }

        
        originalIndexPath = indexPath
        draggingIndexPath = indexPath
        draggingView = cell.snapshotView(afterScreenUpdates: true)
        draggingView?.frame = cell.frame
        cell.isHidden = true
        
        if let draggingView = draggingView {
            cv.addSubview(draggingView)
            
            dragOffset = CGPoint(x: draggingView.center.x - location.x, y: draggingView.center.y - location.y)
            
            invalidateLayout()
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
                draggingView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: nil)
        }
    }
    
    private func updateDragAtLocation(location: CGPoint) {
        guard let view = draggingView else { return }
        guard let cv = collectionView else { return }
        guard let draggingIndexPath = draggingIndexPath else { return }
        guard let delegate = collectionView?.delegate as? MediaRibbonLayoutDelegate else { return }

        view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
        
        if let newIndexPath = cv.indexPathForItem(at: location), delegate.canMoveTo(newIndexPath) {
            cv.moveItem(at: draggingIndexPath, to: newIndexPath)
            self.draggingIndexPath = newIndexPath
        }
    }
    
    private func endDragAtLocation(location: CGPoint) {
        guard let dragView = draggingView else { return }
        guard let indexPath = draggingIndexPath else { return }
        guard let cv = collectionView else { return }
        guard let datasource = cv.dataSource else { return }
        guard let cell = cv.cellForItem(at: indexPath as IndexPath) else { return }
        guard let originalIndexPath = originalIndexPath else { return }
        guard let delegate = collectionView?.delegate as? MediaRibbonLayoutDelegate else { return }

        let targetCenter = datasource.collectionView(cv, cellForItemAt: indexPath as IndexPath).center
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            dragView.center = targetCenter
            dragView.transform = CGAffineTransform.identity
            
        }) { (completed) in
            cell.isHidden = false
            if indexPath != originalIndexPath {
                delegate.moveItemFrom(originalIndexPath, to: indexPath)
            }
            
            dragView.removeFromSuperview()
            self.draggingIndexPath = nil
            self.draggingView = nil
            self.invalidateLayout()
        }
    }
}

protocol MediaRibbonLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func shouldApplyTransformToItemAtIndexPath(_ indexPath: IndexPath) -> Bool
    func canMoveTo(_ indexPath: IndexPath) -> Bool
    func moveItemFrom(_ sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}
