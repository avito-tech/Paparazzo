final class NewCameraPresenter:
    NewCameraModule
{
    // MARK: - Private properties
    private let interactor: NewCameraInteractor
    private let router: NewCameraRouter
    
    // MARK: - Init
    init(
        interactor: NewCameraInteractor,
        router: NewCameraRouter)
    {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Weak properties
    weak var view: NewCameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - NewCameraModule
    var onFinish: ((NewCameraModule, NewCameraModuleResult) -> ())?
    var configureMediaPicker: ((MediaPickerModule) -> ())?
    
    // MARK: - Private
    private func setUpView() {
        
        view?.onCloseButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            self?.onFinish?(strongSelf, .cancelled)
        }
        
        view?.onDoneButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            self?.onFinish?(strongSelf, .finished)
        }
        
        view?.onLastPhotoThumbnailTap = { [weak self] in
            guard let strongSelf = self, let selectedItems = self?.view?.imageStorage.images else { return }
            
            let data = strongSelf.interactor.mediaPickerData.bySettingPhotoLibraryItems(selectedItems)
            
            self?.router.showMediaPicker(
                data: data,
                overridenTheme: nil,
                configure: { module in
                    self?.configureMediaPicker?(module)
                }
            )
        }
    }
}
