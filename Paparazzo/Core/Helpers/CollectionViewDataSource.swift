import UIKit.UICollectionView

final class CollectionViewDataSource<CellType: Customizable>: NSObject, UICollectionViewDataSource {
    
    typealias ItemType = CellType.ItemType
    
    let cellReuseIdentifier: String
    var additionalCellConfiguration: ((CellType, ItemType, UICollectionView, IndexPath) -> ())?
    
    private var items = [ItemType]()
    
    init(cellReuseIdentifier: String) {
        self.cellReuseIdentifier = cellReuseIdentifier
    }
    
    func item(at indexPath: IndexPath) -> ItemType {
        return items[indexPath.row]
    }
    
    func safeItem(at indexPath: IndexPath) -> ItemType? {
        return indexPath.row < items.count ? items[indexPath.row] : nil
    }
    
    func replaceItem(at indexPath: IndexPath, with item: ItemType) {
        items[indexPath.row] = item
    }
    
    func insertItems(_ items: [(item: ItemType, indexPath: IndexPath)]) {
        let sortedItems = items.sorted { $0.indexPath.row < $1.indexPath.row }
        
        let appendedItems = sortedItems.filter { $0.indexPath.row >= self.items.count }
        let insertedItems = sortedItems.filter { $0.indexPath.row < self.items.count }
        
        insertedItems.reversed().forEach { item in
            self.items.insert(item.item, at: item.indexPath.row)
        }
        
        // indexPath'ы тут должны идти последовательно
        self.items.append(contentsOf: appendedItems.map { $0.item })
    }
    
    func deleteAllItems() {
        items = []
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        indexPaths.map { $0.row }.sorted().reversed().forEach { row in
            items.remove(at: row)
        }
    }
    
    func moveItem(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        guard fromIndexPath != toIndexPath else { return }
        
        let fromIndex = fromIndexPath.row
        let toIndex = toIndexPath.row
        
        let item = items.remove(at: fromIndex)
        
        if toIndex > fromIndex {
            items.insert(item, at: toIndex - 1)
        } else {
            items.insert(item, at: toIndex)
        }
    }
    
    func addItem(_ item: ItemType) {
        items.append(item)
    }

    func setItems(_ items: [ItemType]) {
        self.items = items
    }
    
    func mutateItem(at indexPath: IndexPath, mutate: (inout ItemType) -> ()) {
        if var item = safeItem(at: indexPath) {
            mutate(&item)
            replaceItem(at: indexPath, with: item)
        }
    }
    
    /// Mutates item at `indexPath` if it's equal to `theItem`
    func mutateItem<ItemType: Equatable>(_ theItem: ItemType, at indexPath: IndexPath, mutate: (inout ItemType) -> ())
        where ItemType == CellType.ItemType
    {
        mutateItem(at: indexPath) { (item: inout ItemType) in
            if item == theItem {
                mutate(&item)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
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
    
    func customizeWithItem(_ item: ItemType)
}
