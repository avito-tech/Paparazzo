import Foundation

final class PhotoLibraryInteractorImpl: PhotoLibraryInteractor {
    
    // MARK: - Dependencies
    
    private let photoLibraryItemsService: PhotoLibraryItemsService
    
    // MARK: - Init
    
    init(photoLibraryItemsService: PhotoLibraryItemsService) {
        self.photoLibraryItemsService = photoLibraryItemsService
    }
    
    // MARK: - PhotoLibraryInteractor
    
    func observeItems(handler: [PhotoLibraryItem] -> ()) {
        photoLibraryItemsService.observePhotos { lazyImages in
            handler(lazyImages.map { PhotoLibraryItem(image: $0) })
        }
    }
}
