import AVFoundation
import ImageSource // TODO: delete
import UIKit

final class NewCameraViewController:
    PaparazzoViewController,
    NewCameraViewInput
{
    // MARK: - Private properties
    private let cameraView = NewCameraView()
    private let cameraService: CameraService
    private let latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider
    
    let imageStorage: SelectedImageStorage
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return cameraView.cameraOutputLayer
    }
    
    // MARK: - Init
    init(
        selectedImagesStorage: SelectedImageStorage,
        cameraService: CameraService,
        latestLibraryPhotoProvider: PhotoLibraryLatestPhotoProvider)
    {
        self.imageStorage = selectedImagesStorage
        self.cameraService = cameraService
        self.latestLibraryPhotoProvider = latestLibraryPhotoProvider
        
        super.init()
        
        transitioningDelegate = PhotoLibraryToCameraTransitioningDelegate.shared
        
        cameraView.onCaptureButtonTap = { [weak self] in
            self?.cameraView.animateFlash()
            
            self?.cameraService.takePhotoToPhotoLibrary { photo in
                guard let photo = photo, let strongSelf = self else { return }
                
                self?.imageStorage.addItem(photo)
                
                self?.cameraView.animateCapturedPhoto(photo.image) { finalizeAnimation in
                    self?.adjustSelectedPhotosBar {
                        finalizeAnimation()
                    }
                }
            }
        }
        
        latestLibraryPhotoProvider.observePhoto { [weak self] imageSource in
            self?.cameraView.setLatestPhotoLibraryItemImage(imageSource)
        }
        
        // TODO: Move to presenter
        cameraView.onToggleCameraButtonTap = { [weak self] in
            self?.cameraService.toggleCamera { _ in }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Orientation
    override open var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return super.preferredInterfaceOrientationForPresentation
        } else {
            return .portrait
        }
    }
    
    // MARK: - Lifecycle
    private var viewDidLayoutSubviewsBefore = false
    private var didDisappear = false
    
    override var prefersStatusBarHidden: Bool {
        return !UIDevice.current.hasTopSafeAreaInset
    }
    
    override func loadView() {
        view = cameraView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.setFlashButtonVisible(cameraService.isFlashAvailable)
        cameraView.setFlashButtonOn(cameraService.isFlashEnabled)
        
        cameraView.onFlashToggle = { [weak self] isFlashEnabled in
            guard let strongSelf = self else { return }
            
            if !strongSelf.cameraService.setFlashEnabled(isFlashEnabled) {
                strongSelf.cameraView.setFlashButtonOn(!isFlashEnabled)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didDisappear {
            DispatchQueue.main.async {
                self.adjustSelectedPhotosBar {}
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisappear = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !viewDidLayoutSubviewsBefore else { return }
        
        DispatchQueue.main.async {
            self.adjustSelectedPhotosBar {}
        }
        
        viewDidLayoutSubviewsBefore = true
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
    
    var onLastPhotoThumbnailTap: (() -> ())? {
        get { return cameraView.onLastPhotoThumbnailTap }
        set { cameraView.onLastPhotoThumbnailTap = newValue }
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
    
    // MARK: - NewCameraViewController
    func setTheme(_ theme: NewCameraUITheme) {
        cameraView.setTheme(theme)
    }
    
    func setPreviewLayer(_ previewLayer: AVCaptureVideoPreviewLayer?) {
        cameraView.setPreviewLayer(previewLayer)
    }
    
    func previewFrame(forBounds bounds: CGRect) -> CGRect {
        return cameraView.previewFrame(forBounds: bounds)
    }
}
