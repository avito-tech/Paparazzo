import Foundation

protocol PhotoLibraryViewInput: class, ViewLifecycleObservable {
    
    func setCellsData(items: [PhotoLibraryItemCellData])
    func setCanSelectMoreItems(canSelectMoreItems: Bool)
    func setDimsUnselectedItems(dimUnselectedItems: Bool)
    
    var onPickButtonTap: (() -> ())? { get set }
}

struct PhotoLibraryItemCellData {
    
    var image: LazyImage
    var selected = false
    
    var onSelect: (() -> ())?
    var onDeselect: (() -> ())?
    
    init(image: LazyImage) {
        self.image = image
    }
}