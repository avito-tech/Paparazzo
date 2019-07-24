import ImageSource // TODO: delete
import UIKit

final class NewCameraViewController:
    PaparazzoViewController,
    NewCameraViewInput
{
    // MARK: - Private properties
    private let cameraView = NewCameraView()
    private let cameraService: CameraService
    private let imageStorage: SelectedImageStorage
    
    // MARK: - Init
    init(
        selectedImagesStorage: SelectedImageStorage,
        cameraService: CameraService)
    {
        self.imageStorage = selectedImagesStorage
        self.cameraService = cameraService
        
        super.init()
        
        cameraService.getCaptureSession { [weak self] captureSession in
            self?.cameraView.setCaptureSession(captureSession)
        }
        
        cameraView.onCaptureButtonTap = { [weak self] in
            self?.cameraView.animateFlash()
            self?.cameraService.takePhotoToPhotoLibrary { photo in
                guard let photo = photo, let strongSelf = self else { return }
                
                self?.imageStorage.addItem(photo)
                
                self?.cameraView.animateTakenPhoto(photo.image) { finalizeAnimation in
                    self?.adjustSelectedPhotosBar {
                        finalizeAnimation()
                    }
                }
            }
        }
        
        // TODO: Move to presenter
        cameraView.onToggleCameraButtonTap = { [weak self] in
            self?.cameraService.toggleCamera { _ in }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = cameraView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        DispatchQueue.main.async {
//            self.adjustSelectedPhotosBar()
//        }
    }
    
    // MARK: - NewCameraViewInput
    var onCloseButtonTap: (() -> ())? {
        get { return cameraView.onCloseButtonTap }
        set { cameraView.onCloseButtonTap = newValue }
    }
    
    var onDoneButtonTap: (() -> ())? {
        get { return cameraView.onDoneButtonTap }
        set { cameraView.onDoneButtonTap = newValue }
    }
    
//    var onToggleCameraButtonTap: (() -> ())? {
//        get { return cameraView.onToggleCameraButtonTap }
//        set { cameraView.onToggleCameraButtonTap = newValue }
//    }
    
    // MARK: - Private
    func adjustSelectedPhotosBar(completion: @escaping () -> ()) {
        
        let images = imageStorage.images
        
        let state: SelectedPhotosBarState = images.isEmpty
            ? .hidden
            : .visible(SelectedPhotosBarData(
                lastPhoto: images.last?.image,
                penultimatePhoto: images.count > 1 ? images[images.count - 2].image : nil,
                countString: "\(images.count) фото"
            ))
        
        cameraView.setSelectedPhotosBarState(state, completion: completion)
    }
}
