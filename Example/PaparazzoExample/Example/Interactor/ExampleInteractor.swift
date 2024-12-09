import Paparazzo

protocol ExampleInteractor: AnyObject {
    func remoteItems(completion: ([MediaPickerItem]) -> ())
    func photoLibraryItems(completion: ([PhotoLibraryItem]) -> ())
    func setPhotoLibraryItems(_: [PhotoLibraryItem])
}
