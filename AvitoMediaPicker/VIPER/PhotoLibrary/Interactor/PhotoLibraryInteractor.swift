import Foundation

protocol PhotoLibraryInteractor: class {
    
    func observeItems(handler: [PhotoLibraryItem] -> ())
}


struct PhotoLibraryItem {
    let image: LazyImage
}