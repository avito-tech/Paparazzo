import Foundation
import ImageSource

protocol PhotoLibraryV2Interactor: class {
    
    var mediaPickerData: MediaPickerData { get }
    var currentAlbum: PhotoLibraryAlbum? { get }
    var selectedItems: [PhotoLibraryItem] { get }
    var selectedPhotosStorage: SelectedImageStorage { get }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ())
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ())
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ())
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ())
    func observeCurrentAlbumEvents(handler: @escaping (PhotoLibraryAlbumEvent, PhotoLibraryItemSelectionState) -> ())
    
    func isSelected(_: PhotoLibraryItem) -> Bool
    func selectItem(_: PhotoLibraryItem) -> PhotoLibraryItemSelectionState
    func deselectItem(_: PhotoLibraryItem) -> PhotoLibraryItemSelectionState
    func moveSelectedItem(at sourceIndex: Int, to destinationIndex: Int)
    func prepareSelection() -> PhotoLibraryItemSelectionState
    
    func setCurrentAlbum(_: PhotoLibraryAlbum)
    func observeSelectedItemsChange(_: @escaping () -> ())
}
