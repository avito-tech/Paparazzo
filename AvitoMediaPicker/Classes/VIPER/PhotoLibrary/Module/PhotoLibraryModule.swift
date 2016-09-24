import Foundation

public protocol PhotoLibraryModule: class {
    
    func focusOnModule()
    func dismissModule()
    
    var onFinish: ((PhotoLibraryModuleResult) -> ())? { get set }
}

public enum PhotoLibraryModuleResult {
    case selectedItems([PhotoLibraryItem])
    case cancelled
}
