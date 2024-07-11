import ImageSource

protocol NewCameraViewInput: AnyObject {
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
    func setCaptureButtonState(_: CaptureButtonState)
    func setLatestPhotoLibraryItemImage(_: ImageSource?)
    func setSelectedPhotosBarState(_: SelectedPhotosBarState, completion: @escaping () -> ())
    
    func setHintText(_: String)
    func setDoneButtonTitle(_: String)
    func setPlaceholderText(_: String)
    
    func animateFlash()
    func animateCapturedPhoto(
        _: ImageSource,
        completion: @escaping (_ finalizeAnimation: @escaping () -> ()) -> ())
    
    // MARK: - Access denied view
    var onAccessDeniedButtonTap: (() -> ())? { get set }
    
    func setAccessDeniedViewVisible(_: Bool)
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
}

enum CaptureButtonState {
    case enabled
    case nonInteractive  // appears as enabled, but doesn't respond to touches
    case disabled
}
