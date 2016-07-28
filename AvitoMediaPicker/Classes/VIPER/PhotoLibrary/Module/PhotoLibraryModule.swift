import Foundation

public protocol PhotoLibraryModule: class {
    
    func selectItems(_: [PhotoLibraryItem])
    func focusOnModule()
    func dismissModule()
    
    var onFinish: ((selectedItems: [PhotoLibraryItem]) -> ())? { get set }
}