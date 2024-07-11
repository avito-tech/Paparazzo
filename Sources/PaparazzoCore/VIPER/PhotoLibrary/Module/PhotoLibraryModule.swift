import Foundation

public protocol PhotoLibraryModule: AnyObject {
    
    func dismissModule()
    
    var onFinish: ((PhotoLibraryModuleResult) -> ())? { get set }
}

public enum PhotoLibraryModuleResult {
    case selectedItems([PhotoLibraryItem])
    case cancelled
}
