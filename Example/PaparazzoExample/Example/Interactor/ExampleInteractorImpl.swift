import Paparazzo

final class ExampleInteractorImpl: ExampleInteractor {
    
    private var photoLibraryItems = [PhotoLibraryItem]()
    
    // MARK: - ExampleInteractor
    
    func photoLibraryItems(completion: ([PhotoLibraryItem]) -> ()) {
        completion(photoLibraryItems)
    }
    
    func setPhotoLibraryItems(_ items: [PhotoLibraryItem]) {
        photoLibraryItems = items
    }
}
