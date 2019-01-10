import Foundation
import ImageSource

final class PhotoLibraryV2InteractorImpl: PhotoLibraryV2Interactor {
    
    // MARK: - State
    private var maxSelectedItemsCount: Int?
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
        maxSelectedItemsCount: Int? = nil,
        photoLibraryItemsService: PhotoLibraryItemsService,
        cameraService: CameraService,
        deviceOrientationService: DeviceOrientationService,
        canRotate: Bool)
    {
        self.mediaPickerData = mediaPickerData
        self.selectedItems = selectedItems
        self.maxSelectedItemsCount = maxSelectedItemsCount
        self.photoLibraryItemsService = photoLibraryItemsService
        self.cameraService = cameraService
        self.deviceOrientationService = deviceOrientationService
        self.canRotate = canRotate
    }
    
    // MARK: - PhotoLibraryInteractor
    private(set) var currentAlbum: PhotoLibraryAlbum?
    private(set) var selectedItems = [PhotoLibraryItem]()
    
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
                            orientation: orientation,
                            isMetalEnabled: cameraService.isMetalEnabled
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
    
    func isSelected(_ item: PhotoLibraryItem) -> Bool {
        return selectedItems.contains(item)
    }
    
    func selectItem(_ item: PhotoLibraryItem) -> PhotoLibraryItemSelectionState {
        if canSelectMoreItems() {
            selectedItems.append(item)
        }
        return selectionState()
    }
    
    func deselectItem(_ item: PhotoLibraryItem) -> PhotoLibraryItemSelectionState {
        if let index = selectedItems.index(of: item) {
            selectedItems.remove(at: index)
        }
        return selectionState()
    }
    
    func prepareSelection() -> PhotoLibraryItemSelectionState {
        if selectedItems.count > 0 && maxSelectedItemsCount == 1 {
            selectedItems.removeAll()
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
    
    // MARK: - Private
    
    private func canSelectMoreItems() -> Bool {
        return maxSelectedItemsCount.flatMap { selectedItems.count < $0 } ?? true
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
