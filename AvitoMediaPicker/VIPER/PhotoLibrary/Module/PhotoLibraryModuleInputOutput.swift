import Foundation

public protocol PhotoLibraryModuleInput: class {
}

public protocol PhotoLibraryModuleOutput: class {
    func photoLibraryPickerDidFinishWithItems(selectedItems: [PhotoLibraryItem])
}