import Foundation

protocol PhotoLibraryInteractor: class {
    
    func observeItems(handler: [PhotoLibraryItem] -> ())
    
    func selectItem(item: PhotoLibraryItem, completion: (canSelectMoreItems: Bool) -> ())
    func deselectItem(item: PhotoLibraryItem, completion: (canSelectMoreItems: Bool) -> ())
    func selectedItems(completion: (items: [PhotoLibraryItem], canSelectMoreItems: Bool) -> ())
}

public struct PhotoLibraryItem: Equatable {
    
    var identifier: String
    var image: LazyImage
    var selected = false
    
    init(identifier: String, image: LazyImage) {
        self.identifier = identifier
        self.image = image
    }
}

public func ==(item1: PhotoLibraryItem, item2: PhotoLibraryItem) -> Bool {
    return item1.identifier == item2.identifier
}