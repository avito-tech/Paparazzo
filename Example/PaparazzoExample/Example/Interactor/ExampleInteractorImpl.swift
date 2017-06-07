import Paparazzo

final class ExampleInteractorImpl: ExampleInteractor {
    
    private let itemProvider = ItemProvider()
    private var photoLibraryItems = [PhotoLibraryItem]()
    
    // MARK: - ExampleInteractor
    
    func remoteItems(completion: ([MediaPickerItem]) -> ()) {
        completion(itemProvider.remoteItems())
    }
    
    func photoLibraryItems(completion: ([PhotoLibraryItem]) -> ()) {
        completion(photoLibraryItems)
    }
    
    func setPhotoLibraryItems(_ items: [PhotoLibraryItem]) {
        photoLibraryItems = items
    }
}
