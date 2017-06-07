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
        
        setUpGestureRecognizer()
    }
    
    private func setUpGestureRecognizer() {
        if let collectionView = collectionView, longPressGestureRecognizer == nil {
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
            longPressGestureRecognizer.minimumPressDuration = 0.2
            
            // to avoid awkward didHighlight call
            longPressGestureRecognizer.delaysTouchesBegan = true
            self.longPressGestureRecognizer = longPressGestureRecognizer
            
            collectionView.addGestureRecognizer(longPressGestureRecognizer)
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
    
    @objc private func onLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: collectionView)
        switch gestureRecognizer.state {
        case .began: startDragAtLocation(location: location)
        case .changed: updateDragAtLocation(location: location)
        case .ended: endDragAtLocation(location: location)
        default:
            break
        }
    }
    
    private func startDragAtLocation(location: CGPoint) {
        guard
            let collectionView = collectionView,
            let indexPath = collectionView.indexPathForItem(at: location),
            let cell = collectionView.cellForItem(at: indexPath),
            let delegate = collectionView.delegate as? MediaRibbonLayoutDelegate,
            delegate.canMove(to: indexPath) != false
            else { return }

        
        originalIndexPath = indexPath
        draggingIndexPath = indexPath
        draggingView = cell.snapshotView(afterScreenUpdates: false)
        draggingView?.transform = itemsTransform

        draggingView?.frame = cell.frame
        cell.isHidden = true
        
        if let draggingView = draggingView {
            collectionView.addSubview(draggingView)
            dragOffset = CGPoint(x: draggingView.center.x - location.x, y: draggingView.center.y - location.y)
            
            invalidateLayout()

            UIView.animate(
                withDuration: 0.28,
                animations: {
                    draggingView.transform = self.itemsTransform.scaledBy(x: 1.1, y: 1.1)
                },
                completion: nil
            )
        }
    }
    
    private func updateDragAtLocation(location: CGPoint) {
        guard
            let view = draggingView,
            let collectionView = collectionView,
            let draggingIndexPath = draggingIndexPath,
            let delegate = collectionView.delegate as? MediaRibbonLayoutDelegate
            else { return }

        view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
        
        if let newIndexPath = collectionView.indexPathForItem(at: location), delegate.canMove(to: newIndexPath) {
            collectionView.moveItem(at: draggingIndexPath, to: newIndexPath)
            self.draggingIndexPath = newIndexPath
        }
    }
    
    private func endDragAtLocation(location: CGPoint) {
        guard
            let dragView = draggingView,
            let indexPath = draggingIndexPath,
            let collectionView = collectionView,
            let datasource = collectionView.dataSource,
            let cell = collectionView.cellForItem(at: indexPath as IndexPath),
            let originalIndexPath = originalIndexPath,
            let delegate = collectionView.delegate as? MediaRibbonLayoutDelegate
            else { return }

        let targetCenter = datasource.collectionView(collectionView, cellForItemAt: indexPath as IndexPath).center

        UIView.animate(
            withDuration: 0.28,
            animations: {
                dragView.center = targetCenter
                dragView.transform = self.itemsTransform
        },
            completion: { _ in
                cell.isHidden = false
                if indexPath != originalIndexPath {
                    delegate.moveItem(from: originalIndexPath, to: indexPath)
                }
                
                dragView.removeFromSuperview()
                self.draggingIndexPath = nil
                self.draggingView = nil
                self.invalidateLayout()
        })
    }
}

protocol MediaRibbonLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func shouldApplyTransformToItemAtIndexPath(_ indexPath: IndexPath) -> Bool
    func canMove(to indexPath: IndexPath) -> Bool
    func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}
