import Foundation

public protocol PhotoLibraryModule: class {
    
    func focusOnModule()
    func dismissModule()
    
    var onFinish: ((selectedItems: [PhotoLibraryItem]) -> ())? { get set }
}