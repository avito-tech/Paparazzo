import Foundation
import AvitoDesignKit

protocol PhotoLibraryViewInput: class {
    
    func setTitle(_: String)
    func setCancelButtonTitle(_: String)
    func setDoneButtonTitle(_: String)
    
    func setCellsData(items: [PhotoLibraryItemCellData])
    func setCanSelectMoreItems(canSelectMoreItems: Bool)
    func setDimsUnselectedItems(dimUnselectedItems: Bool)
    func setPickButtonEnabled(_: Bool)
    
    func scrollToBottom()
    
    var onPickButtonTap: (() -> ())? { get set }
    var onCancelButtonTap: (() -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
}

struct PhotoLibraryItemCellData {
    
    var image: ImageSource
    var selected = false
    
    var onSelect: (() -> ())?
    var onDeselect: (() -> ())?
    
    init(image: ImageSource) {
        self.image = image
    }
}