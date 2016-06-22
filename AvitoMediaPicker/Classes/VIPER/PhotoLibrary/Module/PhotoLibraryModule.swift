import Foundation

public protocol PhotoLibraryModule: class {
    
    func setMaxItemsCount(_: Int?)
    func selectItems(_: [PhotoLibraryItem])
    
    var onFinish: ((selectedItems: [PhotoLibraryItem]) -> ())? { get set }
}