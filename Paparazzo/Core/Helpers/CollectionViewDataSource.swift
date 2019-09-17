import UIKit.UICollectionView

final class CollectionViewDataSource<CellType: Customizable>: NSObject, UICollectionViewDataSource {
    typealias ItemType = CellType.ItemType
    
    let cellReuseIdentifier: String
    let headerReuseIdentifier: String?
    var additionalCellConfiguration: ((CellType, ItemType, UICollectionView, IndexPath) -> ())?
    var configureHeader: ((UIView) -> ())?
    
    private var items = [ItemType]()
    
    init(
        cellReuseIdentifier: String,
        headerReuseIdentifier: String? = nil)
    {
        self.cellReuseIdentifier = cellReuseIdentifier
        self.headerReuseIdentifier = headerReuseIdentifier
    }
    
    func item(at indexPath: IndexPath) -> ItemType {
        return items[indexPath.item]
    }
    
    func safeItem(at indexPath: IndexPath) -> ItemType? {
        return indexPath.item < items.count ? items[indexPath.item] : nil
    }
    
    func replaceItem(at indexPath: IndexPath, with item: ItemType) {
        items[indexPath.item] = item
    }
    
    func insertItems(_ items: [(item: ItemType, indexPath: IndexPath)]) {
        let sortedItems = items.sorted { $0.indexPath.row < $1.indexPath.row }
        
        sortedItems.forEach { item in
            if item.indexPath.row > self.items.count {
                self.items.append(item.item)
            } else {
                self.items.insert(item.item, at: item.indexPath.row)
            }
        }
    }
    
    func deleteAllItems() {
        items = []
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        indexPaths.map { $0.item }.sorted().reversed().forEach { row in
            items.remove(at: row)
        }
    }
    
    func moveItem(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        guard fromIndexPath != toIndexPath else { return }
        
        let fromIndex = fromIndexPath.item
        let toIndex = toIndexPath.item
        
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
    
    func indexPath(where findItem: (ItemType) -> Bool) -> IndexPath? {
        return items.index(where: findItem).flatMap { IndexPath(item: $0, section: 0) }
    }
    
    func indexPaths(where findItem: (ItemType) -> Bool) -> [IndexPath] {
        return items.enumerated()
            .flatMap { findItem($0.element) ? $0.offset : nil }
            .map { IndexPath(item: $0, section: 0) }
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView
    {
        guard let headerReuseIdentifier = headerReuseIdentifier, kind == UICollectionView.elementKindSectionHeader else {
            preconditionFailure("Invalid supplementary view type for this collection view")
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: headerReuseIdentifier,
            for: indexPath
        )
        assert(configureHeader != nil)
        configureHeader?(view)
        return view
    }
}

protocol Customizable {
    associatedtype ItemType
    
    func customizeWithItem(_ item: ItemType)
}
