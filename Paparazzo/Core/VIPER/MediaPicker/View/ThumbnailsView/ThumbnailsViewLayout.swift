import UIKit

final class ThumbnailsViewLayout: UICollectionViewLayout {
    
    var itemsTransform = CGAffineTransform.identity
    var hapticFeedbackEnabled = false
    var sectionInset = UIEdgeInsets.zero
    var spacing = CGFloat(0)
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    private var originalIndexPath: IndexPath?
    private var draggingIndexPath: IndexPath?
    private var draggingView: UIView?
    private var dragOffset = CGPoint.zero
    private var attributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize = CGSize.zero
    
    var onDragStart: (() -> ())?
    var onDragFinish: (() -> ())?
    
    override func prepare() {
        super.prepare()
        
        attributes.removeAll()
        
        let itemsCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        let collectionViewBounds = collectionView?.bounds ?? .zero
        let height = collectionViewBounds.size.height - sectionInset.top - sectionInset.bottom
        let width = height
        var maxX = CGFloat(0)
        
        for index in 0..<itemsCount {
            
            let indexPath = IndexPath(item: index, section: 0)
            let frame = CGRect(
                centerX: sectionInset.left + width / 2 + CGFloat(index) * (width + spacing),
                centerY: collectionViewBounds.midY,
                width: width,
                height: height
            )
            
            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttributes.bounds = CGRect(origin: .zero, size: frame.size)
            cellAttributes.center = frame.center
            
            attributes[indexPath] = cellAttributes
            
            maxX = frame.maxX
        }
        
        contentSize = CGSize(
            width: maxX + sectionInset.right,
            height: collectionViewBounds.height
        )
        
        setUpGestureRecognizer()
    }
    
    func cancelDrag() {
        longPressGestureRecognizer?.isEnabled = false
        longPressGestureRecognizer?.isEnabled = true
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
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds != collectionView?.bounds
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = self.attributes[indexPath] else { return nil }
        adjustAttributes(attributes)
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = self.attributes.filter { $1.frame.intersects(rect) }.map { $1 }
        attributes.forEach { adjustAttributes($0) }
        return attributes
    }
    
    // MARK: - Private
    
    private func adjustAttributes(_ attributes: UICollectionViewLayoutAttributes?) {
        guard let attributes = attributes else { return }
        
        let delegate = collectionView?.delegate as? MediaRibbonLayoutDelegate
        let shouldApplyTransform = delegate?.shouldApplyTransformToItemAtIndexPath(attributes.indexPath) ?? true
        
        attributes.transform = shouldApplyTransform ? itemsTransform : .identity
    }
    
    @objc private func onLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: collectionView)
        switch gestureRecognizer.state {
        case .began: startDragAtLocation(location: location)
        case .changed: updateDragAtLocation(location: location)
        case .ended: endDragAtLocation(location: location)
        case .cancelled: endDragAtLocation(location: location)
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

        if #available(iOS 10.0, *), hapticFeedbackEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
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
            
            onDragStart?()
        }
    }
    
    private func updateDragAtLocation(location: CGPoint) {
        guard
            let view = draggingView
            else { return }

        view.center = CGPoint(x: location.x + dragOffset.x, y: location.y + dragOffset.y)
        
        moveItem(to: location)
    }
    
    private func endDragAtLocation(location: CGPoint) {
        guard
            let dragView = draggingView,
            let indexPath = draggingIndexPath,
            let collectionView = collectionView,
            let datasource = collectionView.dataSource,
            let cell = collectionView.cellForItem(at: indexPath as IndexPath),
            originalIndexPath != nil,
            collectionView.delegate as? MediaRibbonLayoutDelegate != nil
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
                dragView.removeFromSuperview()
                self.draggingIndexPath = nil
                self.draggingView = nil
                self.invalidateLayout()
                self.onDragFinish?()

        })
    }
    
    private func indexPathForItemClosestTo(point: CGPoint) -> IndexPath? {
        guard
            let collectionView = collectionView,
            let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForElements(in: collectionView.bounds)
        else { return nil }
        
        var smallestDistance = CGFloat.greatestFiniteMagnitude
        var indexPath: IndexPath?
        
        for attribute in layoutAttributes {
            if attribute.frame.contains(point) {
                return attribute.indexPath
            }
            
            let currentDistance = abs(attribute.frame.x - point.x)
            if smallestDistance > currentDistance {
                smallestDistance = currentDistance
                indexPath = attribute.indexPath
            }
        }
        
        return indexPath
    }
    
    private func moveItem(to location: CGPoint) {
        guard
            let collectionView = collectionView,
            let draggingIndexPath = draggingIndexPath,
            let delegate = collectionView.delegate as? MediaRibbonLayoutDelegate
            else { return }
        
        // AI-6314: If we pass location inside indexPathForItem it can return nil if location is out of collectionView bounds
        if let newIndexPath = indexPathForItemClosestTo(point: CGPoint(x: location.x, y: collectionView.height/2)),
            delegate.canMove(to: newIndexPath),
            draggingIndexPath != newIndexPath {
            delegate.moveItem(from: draggingIndexPath, to: newIndexPath)
            collectionView.moveItem(at: draggingIndexPath, to: newIndexPath)
            self.draggingIndexPath = newIndexPath
        }
        beginScrollIfNeeded()
    }
    
    // MARK: Handle scrolling to the edges
   
    private var continuousScrollDirection: direction = .none

    enum direction {
        case left
        case right
        case none
        
        func scrollValue(_ speedValue: CGFloat, percentage: CGFloat) -> CGFloat {
            var value: CGFloat = 0.0
            switch self {
            case .left:
                value = -speedValue
            case .right:
                value = speedValue
            case .none:
                return 0
            }
            
            let proofedPercentage: CGFloat = max(0, min(percentage, 1.0))
            return value * proofedPercentage
        }
    }
    

    private let triggerInset : CGFloat = 30.0
    
    private var scrollSpeedValue: CGFloat = 5.0
    private var displayLink: CADisplayLink?

    private var offsetFromLeft: CGFloat {
        return collectionView?.contentOffset.x ?? 0
    }
    
    private var collectionViewWidth: CGFloat {
        return collectionView?.bounds.size.width ?? 0
    }
    
    private var contentLength: CGFloat {
        return collectionView?.contentSize.width ?? 0
    }
    
    private var draggingViewTopEdge: CGFloat? {
        return draggingView.flatMap { $0.frame.minX }
    }
    
    private var draggingViewEndEdge: CGFloat? {
        return draggingView.flatMap { $0.frame.maxX }
    }
    
    private func setUpDisplayLink() {
        guard self.displayLink == nil else { return }
        
        let displayLink = CADisplayLink(target: self, selector: #selector(onContinuousScroll))
        displayLink.frameInterval = 1
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        self.displayLink = displayLink
    }
    
    private func invalidateDisplayLink() {
        continuousScrollDirection = .none
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func beginScrollIfNeeded() {
        guard
            let draggingViewTopEdge = draggingViewTopEdge,
            let draggingViewEndEdge = draggingViewEndEdge
            else { return }
        
        if draggingViewTopEdge <= offsetFromLeft + triggerInset {
            continuousScrollDirection = .left
            setUpDisplayLink()
        } else if draggingViewEndEdge >= offsetFromLeft + collectionViewWidth - triggerInset {
            continuousScrollDirection = .right
            setUpDisplayLink()
        } else {
            invalidateDisplayLink()
        }
    }
    
    @objc private func onContinuousScroll() {
        guard let draggingView = draggingView else { return }
        
        let percentage = calculateTriggerPercentage()
        var scrollRate = continuousScrollDirection.scrollValue(scrollSpeedValue, percentage: percentage)
        
        let offset = offsetFromLeft
        let length = collectionViewWidth
        
        if contentLength <= length {
            return
        }
        
        if offset + scrollRate <= 0 {
            scrollRate = -offset
        } else if offset + scrollRate >= contentLength - length {
            scrollRate = contentLength - length - offset
        }

        draggingView.x += scrollRate
        self.collectionView?.contentOffset.x += scrollRate
        moveItem(to: draggingView.center)
    }
    
    private func calculateTriggerPercentage() -> CGFloat {
        guard draggingView != nil else { return 0 }
        
        let offset = offsetFromLeft
        let offsetEnd = offsetFromLeft + collectionViewWidth
        
        var percentage: CGFloat = 0
        
        guard triggerInset != 0 else {
            return 0
        }
        
        if self.continuousScrollDirection == .left {
            if let fakeCellEdge = draggingViewTopEdge {
                percentage = 1.0 - ((fakeCellEdge - offset) / triggerInset)
            }
        } else if continuousScrollDirection == .right {
            if let draggingViewEdge = draggingViewEndEdge {
                percentage = 1.0 - ((offsetEnd - draggingViewEdge) / triggerInset)
            }
        }
        
        percentage = min(1, max(0, percentage))
        return percentage
    }
}

protocol MediaRibbonLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func shouldApplyTransformToItemAtIndexPath(_ indexPath: IndexPath) -> Bool
    func canMove(to indexPath: IndexPath) -> Bool
    func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}
