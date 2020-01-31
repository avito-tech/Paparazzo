import Foundation
import ImageSource

final class PhotoLibraryV2InteractorImpl: PhotoLibraryV2Interactor {
    
    // MARK: - State
    private var onAlbumEvent: ((PhotoLibraryAlbumEvent, PhotoLibraryItemSelectionState) -> ())?
    
    // MARK: - Dependencies
    private let photoLibraryItemsService: PhotoLibraryItemsService
    private let cameraService: CameraService
    private let deviceOrientationService: DeviceOrientationService
    private let canRotate: Bool
    
    // MARK: - Properties
    let mediaPickerData: MediaPickerData
    
    // MARK: - Init
    init(
        mediaPickerData: MediaPickerData,
        selectedItems: [PhotoLibraryItem],
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
    
    func observeAuthorizationStatus(handler: @escaping (_ accessGranted: Bool) -> ()) {
        photoLibraryItemsService.observeAuthorizationStatus(handler: handler)
    }
    
    func observeAlbums(handler: @escaping ([PhotoLibraryAlbum]) -> ()) {
        photoLibraryItemsService.observeAlbums { [weak self] albums in
            if let currentAlbum = self?.currentAlbum {
                // Reset current album if it has been removed, otherwise refresh it (title might have been changed).
                self?.currentAlbum = albums.first { $0 == currentAlbum }
            }
            handler(albums)
        }
    }
    
    func observeCurrentAlbumEvents(handler: @escaping (PhotoLibraryAlbumEvent, PhotoLibraryItemSelectionState) -> ()) {
        onAlbumEvent = handler
    }
    
    func isSelected(_ item: MediaPickerItem) -> Bool {
        return selectedItems.contains(item)
    }
    
    func selectItem(_ item: MediaPickerItem) -> PhotoLibraryItemSelectionState {
        if canSelectMoreItems() {
            selectedPhotosStorage.addItem(item)
        }
        return selectionState()
    }
    
    func replaceSelectedItem(at index: Int, with item: MediaPickerItem) {
        selectedPhotosStorage.replaceItem(at: index, with: item)
    }
    
    func deselectItem(_ item: MediaPickerItem) -> PhotoLibraryItemSelectionState {
        selectedPhotosStorage.removeItem(item)
        return selectionState()
    }
    
    func moveSelectedItem(at sourceIndex: Int, to destinationIndex: Int) {
        selectedPhotosStorage.moveItem(at: sourceIndex, to: destinationIndex)
    }
    
    func prepareSelection() -> PhotoLibraryItemSelectionState {
        if selectedItems.count > 0 && mediaPickerData.maxItemsCount == 1 {
            selectedPhotosStorage.removeAllItems()
            return selectionState(preSelectionAction: .deselectAll)
        } else {
            return selectionState()
        }
    }
    
    func setCurrentAlbum(_ album: PhotoLibraryAlbum) {
        guard album != currentAlbum else { return }
        
        currentAlbum = album
        
        photoLibraryItemsService.observeEvents(in: album) { [weak self] event in
            guard let strongSelf = self else { return }
            
            // TODO: (ayutkin) find a way to remove items in `selectedItems` that refer to removed assets
            
            if let onAlbumEvent = strongSelf.onAlbumEvent {
                dispatch_to_main_queue {
                    onAlbumEvent(event, strongSelf.selectionState())
                }
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
    
    private func selectionState(preSelectionAction: PhotoLibraryItemSelectionState.PreSelectionAction = .none) -> PhotoLibraryItemSelectionState {
        return PhotoLibraryItemSelectionState(
            isAnyItemSelected: selectedItems.count > 0,
            canSelectMoreItems: canSelectMoreItems(),
            preSelectionAction: preSelectionAction
        )
    }
}

extension ExifOrientation {
    func byApplyingDeviceOrientation(_ orientation: DeviceOrientation) -> ExifOrientation {
        switch orientation {
        case .portrait:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        case .portraitUpsideDown:
            return .right
        case .unknown:
            return .left
        }
    }
}
