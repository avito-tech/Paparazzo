import ImageSource

protocol NewCameraViewInput: class {
    var onCloseButtonTap: (() -> ())? { get set }
    var onDoneButtonTap: (() -> ())? { get set }
    var onToggleCameraButtonTap: (() -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    var onFlashToggle: ((Bool) -> ())? { get set }
    var onCaptureButtonTap: (() -> ())? { get set }
    
    var onViewWillAppear: ((_ animated: Bool) -> ())? { get set }
    var onViewDidDisappear: ((_ animated: Bool) -> ())? { get set }
    var onViewDidLayoutSubviews: (() -> ())? { get set }
    
    func setFlashButtonVisible(_: Bool)
    func setFlashButtonOn(_: Bool)
    func setLatestPhotoLibraryItemImage(_: ImageSource?)
    func setSelectedPhotosBarState(_: SelectedPhotosBarState, completion: @escaping () -> ())
    
    func animateFlash()
    func animateCapturedPhoto(
        _: ImageSource,
        completion: @escaping (_ finalizeAnimation: @escaping () -> ()) -> ())
}
