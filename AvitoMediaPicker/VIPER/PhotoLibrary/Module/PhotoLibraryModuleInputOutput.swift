import Foundation

public protocol PhotoLibraryModuleInput: class {
}

public protocol PhotoLibraryModuleOutput: class {
    // TODO: возможно, тут надо возвращать не PhotoLibraryItem, а что-то другое (у PhotoLibraryItem есть selected, оно нафиг не надо)
    func photoLibraryPickerDidFinishWithItems(selectedItems: [PhotoLibraryItem])
}