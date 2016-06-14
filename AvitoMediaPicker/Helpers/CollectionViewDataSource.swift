import UIKit.UICollectionView

final class CollectionViewDataSource<CellType: Customizable>: NSObject, UICollectionViewDataSource {
    
    typealias ItemType = CellType.ItemType
    
    let cellReuseIdentifier: String
    var onDataChanged: (() -> ())?
    
    private var items = [ItemType]()
    
    init(cellReuseIdentifier: String) {
        self.cellReuseIdentifier = cellReuseIdentifier
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> ItemType {
        return items[indexPath.row]
    }
    
    func addItem(item: ItemType) {
        items.append(item)
        notifyAboutDataChange()
    }

    func setItems(items: [ItemType]) {
        self.items = items
        notifyAboutDataChange()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        let item = itemAtIndexPath(indexPath)
        
        if let cell = cell as? CellType {
            cell.customizeWithItem(item)
        }
        
        return cell
    }

    // MARK: - Private

    private func notifyAboutDataChange() {
        dispatch_async(dispatch_get_main_queue()) {
            self.onDataChanged?()
        }
    }
}

protocol Customizable {
    associatedtype ItemType
    
    func customizeWithItem(item: ItemType)
}