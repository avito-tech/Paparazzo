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
            self?.cameraService.takePhotoToPhotoLibrary { photo in
                guard let photo = photo, let strongSelf = self else { return }
                
                self?.imageStorage.addItem(photo)
                self?.adjustSelectedPhotosBar()
            }
        }
        
        adjustSelectedPhotosBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = cameraView
    }
    
    // MARK: - NewCameraViewInput
    var onCloseButtonTap: (() -> ())? {
        get { return cameraView.onCloseButtonTap }
        set { cameraView.onCloseButtonTap = newValue }
    }
    
    // MARK: - Private
    func adjustSelectedPhotosBar() {
        let images = imageStorage.images
        
        cameraView.setSelectedPhotosBarState(images.isEmpty
            ? .hidden
            : .visible(SelectedPhotosBarData(
                lastPhoto: images.last?.image,
                penultimatePhoto: images.count > 1 ? images[images.count - 2].image : nil,
                countString: "\(images.count) фото"
            ))
        )
    }
}
