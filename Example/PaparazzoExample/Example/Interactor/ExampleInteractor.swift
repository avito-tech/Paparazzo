import Paparazzo

protocol ExampleInteractor: class {
    func remoteItems(completion: ([MediaPickerItem]) -> ())
    func photoLibraryItems(completion: ([PhotoLibraryItem]) -> ())
    func setPhotoLibraryItems(_: [PhotoLibraryItem])
}
