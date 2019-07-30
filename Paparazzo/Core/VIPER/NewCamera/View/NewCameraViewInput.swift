protocol NewCameraViewInput: class {
    var onCloseButtonTap: (() -> ())? { get set }
    var onDoneButtonTap: (() -> ())? { get set }
//    var onToggleCameraButtonTap: (() -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    
    // TODO: move to interactor
    var imageStorage: SelectedImageStorage { get }
}
