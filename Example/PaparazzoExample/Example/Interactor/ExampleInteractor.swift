import Paparazzo

protocol ExampleInteractor: class {
    func photoLibraryItems(completion: ([PhotoLibraryItem]) -> ())
    func setPhotoLibraryItems(_: [PhotoLibraryItem])
}
