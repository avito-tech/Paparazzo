import Foundation

public protocol PhotoLibraryModule: class {
    
    func selectItems(_: [PhotoLibraryItem])
    
    var onFinish: ((selectedItems: [PhotoLibraryItem]) -> ())? { get set }
}