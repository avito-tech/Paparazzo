import Foundation
import ImageSource

final class PhotoLibraryV3InteractorImpl: PhotoLibraryV3Interactor {
    
    // MARK: - State
    private var onAlbumEvent: ((PhotoLibraryV3AlbumEvent, PhotoLibraryV3ItemSelectionState) -> ())?
    
    // MARK: - Dependencies
    private let photoLibraryItemsService: PhotoLibraryItemsService
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let canRotate: Bool
    
    // MARK: - Properties
    let mediaPickerData: MediaPickerData
    
    var onLimitedAccess: (() -> ())? {
        get { return photoLibraryItemsService.onLimitedAccess }
        set { photoLibraryItemsService.onLimitedAccess = newValue }
    }
    
    // MARK: - Init
    init(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryV3Item],
        photoLibraryItemsService: PhotoLibraryItemsService,
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        canRotate: Bool)
    {
        self.mediaPickerData = mediaPickerData
        self.selectedPhotosStorage = SelectedImageStorage(images: mediaPickerData.items)
        self.photoLibraryItemsService = photoLibraryItemsService
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.canRotate = canRotate
    }
    
    // MARK: - PhotoLibraryInteractor
    let selectedPhotosStorage: SelectedImageStorage
    private(set) var currentAlbum: PhotoLibraryAlbum?
    
    var selectedItems: [MediaPickerItem] {
        return selectedPhotosStorage.images
    }
    
    func observeDeviceOrientation(handler: @escaping (DeviceOrientation) -> ()) {
        deviceOrientationService.onOrientationChange = handler
        handler(deviceOrientationService.currentOrientation)
    }
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ()) {
        cameraService.getCaptureSession { [cameraService] captureSession in
            cameraService.getOutputOrientation { [weak self] outputOrientation in
                guard let strongSelf = self else {
                    completion(nil)
                    return
                }
                var orientation = outputOrientation
                if strongSelf.canRotate {
                    orientation = outputOrientation.byApplyingDeviceOrientation(
                        strongSelf.deviceOrientationService.currentOrientation
                    )
                }
                dispatch_to_main_queue {
                    completion(captureSession.flatMap {
                        CameraOutputParameters(
                            captureSession: $0,
                            orientation: orientation
                        )
                    })
                }
            }
        }
    }
    
    func setCameraOutputNeeded(_ isCameraOutputNeeded: Bool) {
        cameraService.setCaptureSessionRunning(isCameraOutputNeeded)
    }
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        photoLibraryItemsService.observeAuthorizationStatus(handler: handler)
    }
    
    func observeLimitedAccess(handler: @escaping () -> ()) {
        photoLibraryItemsService.observeLimitedAccess(handler: handler)
    }
    
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ()) {
        photoLibraryItemsService.observeAlbums { [weak self] albums in
            guard let self else { return }
            
            self.currentAlbum = albums.first { $0 == self.currentAlbum }
            handler(albums)
        }
    }
    
    func observeCurrentAlbumEvents(handler: @escaping (PhotoLibraryV3AlbumEvent, PhotoLibraryV3ItemSelectionState) -> ()) {
        onAlbumEvent = handler
    }
    
    func isSelected(_ item: MediaPickerItem) -> Bool {
        return selectedItems.contains(item)
    }
    
    func selectItem(_ item: MediaPickerItem) -> PhotoLibraryV3ItemSelectionState {
        if canSelectMoreItems() {
            selectedPhotosStorage.addItem(item)
        }
        return selectionState()
    }
    
    func replaceSelectedItem(at index: Int, with item: MediaPickerItem) {
        selectedPhotosStorage.replaceItem(at: index, with: item)
    }
    
    func deselectItem(_ item: MediaPickerItem) -> PhotoLibraryV3ItemSelectionState {
        selectedPhotosStorage.removeItem(item)
        return selectionState()
    }
    
    func moveSelectedItem(at sourceIndex: Int, to destinationIndex: Int) {
        selectedPhotosStorage.moveItem(at: sourceIndex, to: destinationIndex)
    }
    
    func prepareSelection() -> PhotoLibraryV3ItemSelectionState {
        if selectedItems.count > 0 && mediaPickerData.maxItemsCount == 1 {
            selectedPhotosStorage.removeAllItems()
            return selectionState(preSelectionAction: .deselectAll)
        } else {
            return selectionState()
        }
    }
    
    func setCurrentAlbum(_ album: PhotoLibraryAlbum) {
        currentAlbum = album
        
        photoLibraryItemsService.observeEvents(in: album) { [weak self] event in
            guard let self else { return }
            
            // TODO: (ayutkin) find a way to remove items in `selectedItems` that refer to removed assets
            
            dispatch_to_main_queue {
                self.onAlbumEvent?(event.asV3, self.selectionState())
            }
        }
    }
    
    func observeSelectedItemsChange(_ onChange: @escaping () -> ()) {
        selectedPhotosStorage.observeImagesChange(onChange)
    }
    
    // MARK: - Private
    
    private func canSelectMoreItems() -> Bool {
        return mediaPickerData.maxItemsCount.flatMap { selectedItems.count < $0 } ?? true
    }
    
    private func selectionState(preSelectionAction: PhotoLibraryV3ItemSelectionState.PreSelectionAction = .none) -> PhotoLibraryV3ItemSelectionState {
        return PhotoLibraryV3ItemSelectionState(
            isAnyItemSelected: selectedItems.count > 0,
            canSelectMoreItems: canSelectMoreItems(),
            preSelectionAction: preSelectionAction
        )
    }
}
