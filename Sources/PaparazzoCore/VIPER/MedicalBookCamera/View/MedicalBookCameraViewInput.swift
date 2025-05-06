import AVFoundation

protocol MedicalBookCameraViewInput: AnyObject {
    var onViewWillAppear: ((_ animated: Bool) -> ())? { get set }
    var onViewDidDisappear: ((_ animated: Bool) -> ())? { get set }
    var onViewDidLayoutSubviews: (() -> ())? { get set }
    
    var onCloseButtonTap: (() -> ())? { get set }
    var onToggleCameraButtonTap: (() -> ())? { get set }
    var onFlashToggle: ((Bool) -> ())? { get set }
    var onShutterButtonTap: (() -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    
    var onAccessDeniedButtonTap: (() -> ())? { get set }

    func setFlashButtonVisible(_ flag: Bool)
    func setFlashButtonOn(_ flag: Bool)
    func animateShot()
    func setShutterButtonEnabled(_ flag: Bool, _ animated: Bool)
    func setHintText(_ text: String)
    func setSelectedData(_ viewData: SelectedPhotosViewData?, animated: Bool)
    func setSelectedDataEnabled(_ flag: Bool)
    
    func setAccessDeniedViewVisible(_ flag: Bool)
    func setAccessDeniedTitle(_ title: String)
    func setAccessDeniedMessage(_ message: String)
    func setAccessDeniedButtonTitle(_ title: String)
}
