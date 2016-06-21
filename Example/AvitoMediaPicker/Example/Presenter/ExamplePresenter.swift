import AvitoMediaPicker

final class ExamplePresenter: MediaPickerModuleOutput, PhotoLibraryModuleOutput {
    
    private let interactor: ExampleInteractor
    private let router: ExampleRouter
    
    weak var view: ExampleViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Init
    
    init(interactor: ExampleInteractor, router: ExampleRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.onShowMediaPickerButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            self?.router.showMediaPicker(5, output: strongSelf)
        }
        
        view?.onShowPhotoLibraryButtonTap = { [weak self] in
            guard let strongSelf = self else { return }
            self?.router.showPhotoLibrary(5, output: strongSelf)
        }
    }
    
    // MARK: - MediaPickerModuleOutput

    func photoPickerDidAddItem(item: MediaPickerItem) {
    }

    func photoPickerDidUpdateItem(item: MediaPickerItem) {
    }

    func photoPickerDidRemoveItem(item: MediaPickerItem) {
    }

    func photoPickerDidFinish() {
    }

    func photoPickerDidCancel() {
    }

    // MARK: - PhotoLibraryModuleOutput

    func photoLibraryPickerDidFinishWithItems(selectedItems: [PhotoLibraryItem]) {
    }
}
