import UIKit.UICollectionView

final class CollectionViewDataSource<CellType: Customizable>: NSObject, UICollectionViewDataSource {
    
    typealias ItemType = CellType.ItemType
    
    let cellReuseIdentifier: String
    var onDataChanged: (() -> ())?
    
    private var items = [ItemType]()
    
    init(cellReuseIdentifier: String) {
        self.cellReuseIdentifier = cellReuseIdentifier
    }
    
    func item(atIndexPath indexPath: NSIndexPath) -> ItemType {
        return items[indexPath.row]
    }
    
    func replaceItem(atIndexPath indexPath: NSIndexPath, with item: ItemType) {
        items[indexPath.row] = item
    }
    
    func addItem(item: ItemType) {
        items.append(item)
        notifyAboutDataChange()
    }

    func setItems(items: [ItemType]) {
        self.items = items
        notifyAboutDataChange()
    }
    
    func mutateItem(atIndexPath indexPath: NSIndexPath, mutator: (inout ItemType) -> ()) {
        
        var item = self.item(atIndexPath: indexPath)
        mutator(&item)
        
        replaceItem(atIndexPath: indexPath, with: item)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        let item = self.item(atIndexPath: indexPath)
        
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