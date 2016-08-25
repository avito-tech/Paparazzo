import UIKit.UICollectionView

final class CollectionViewDataSource<CellType: Customizable>: NSObject, UICollectionViewDataSource {
    
    typealias ItemType = CellType.ItemType
    
    let cellReuseIdentifier: String
    var onDataChanged: (() -> ())?
    var additionalCellConfiguration: ((CellType, ItemType, UICollectionView, NSIndexPath) -> ())?
    
    private var items = [ItemType]()
    
    init(cellReuseIdentifier: String) {
        self.cellReuseIdentifier = cellReuseIdentifier
    }
    
    func item(at indexPath: NSIndexPath) -> ItemType {
        return items[indexPath.row]
    }
    
    func replaceItem(at indexPath: NSIndexPath, with item: ItemType) {
        items[indexPath.row] = item
    }
    
    func insertItems(items: [(item: ItemType, indexPath: NSIndexPath)]) {
        let sortedItems = items.sort { $0.indexPath.row < $1.indexPath.row }
        
        let appendedItems = sortedItems.filter { $0.indexPath.row >= self.items.count }
        let insertedItems = sortedItems.filter { $0.indexPath.row < self.items.count }
        
        insertedItems.reverse().forEach { item in
            self.items.insert(item.item, atIndex: item.indexPath.row)
        }
        
        // indexPath'ы тут должны идти последовательно
        self.items.appendContentsOf(appendedItems.map { $0.item })
    }
    
    func deleteItems(at indexPaths: [NSIndexPath]) {
        indexPaths.map { $0.row }.sort().reverse().forEach { row in
            items.removeAtIndex(row)
        }
    }
    
    func moveItem(at fromIndexPath: NSIndexPath, to toIndexPath: NSIndexPath) {
        guard fromIndexPath != toIndexPath else { return }
        
        let fromIndex = fromIndexPath.row
        let toIndex = toIndexPath.row
        
        let item = items.removeAtIndex(fromIndex)
        
        if toIndex > fromIndex {
            items.insert(item, atIndex: toIndex - 1)
        } else {
            items.insert(item, atIndex: toIndex)
        }
    }
    
    func addItem(item: ItemType) {
        items.append(item)
    }

    func setItems(items: [ItemType]) {
        self.items = items
    }
    
    func mutateItem(atIndexPath indexPath: NSIndexPath, mutator: (inout ItemType) -> ()) {
        
        var item = self.item(at: indexPath)
        mutator(&item)
        
        replaceItem(at: indexPath, with: item)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        let item = self.item(at: indexPath)
        
        if let cell = cell as? CellType {
            cell.customizeWithItem(item)
            additionalCellConfiguration?(cell, item, collectionView, indexPath)
        }
        
        return cell
    }
}

protocol Customizable {
    associatedtype ItemType
    
    func customizeWithItem(item: ItemType)
}