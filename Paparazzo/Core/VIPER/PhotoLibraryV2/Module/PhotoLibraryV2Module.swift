import Foundation

public protocol PhotoLibraryV2Module: class {
    
    func dismissModule()
    
    var onFinish: ((PhotoLibraryV2ModuleResult) -> ())? { get set }
}

public enum PhotoLibraryV2ModuleResult {
    case selectedItems([PhotoLibraryItem])
    case cancelled
}
