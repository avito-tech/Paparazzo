public protocol MediaPickerModule: class {
    
    func setItems(_: [MediaPickerItem], selectedItem: MediaPickerItem?)

    var onItemsAdd: ([MediaPickerItem] -> ())? { get set }
    var onItemUpdate: (MediaPickerItem -> ())? { get set }
    var onItemRemove: (MediaPickerItem -> ())? { get set }

    var onFinish: ([MediaPickerItem] -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}