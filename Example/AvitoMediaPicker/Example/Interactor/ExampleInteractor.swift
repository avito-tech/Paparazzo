import AvitoMediaPicker

protocol ExampleInteractor: class {
    
    func photoLibraryItems(completion: [PhotoLibraryItem] -> ())
    func setPhotoLibraryItems(items: [PhotoLibraryItem])
}