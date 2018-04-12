import Foundation

public protocol PhotoLibraryV2Module: class {
    
    func dismissModule()
    
    var onFinish: ((PhotoLibraryV2ModuleResult) -> ())? { get set }
    
    func setContinueButtonTitle(_: String)
}

public enum PhotoLibraryV2ModuleResult {
    case selectedItems([MediaPickerItem])
    case cancelled
}
