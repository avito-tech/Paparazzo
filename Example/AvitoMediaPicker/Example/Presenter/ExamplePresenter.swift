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

    func mediaPickerDidAddItems(items: [MediaPickerItem]) {
        print("mediaPickerDidAddItems")
    }

    func mediaPickerDidUpdateItem(item: MediaPickerItem) {
        print("mediaPickerDidUpdateItem")
    }

    func mediaPickerDidRemoveItem(item: MediaPickerItem) {
        print("mediaPickerDidRemoveItem")
    }

    func mediaPickerDidFinish(withItems items: [MediaPickerItem]) {
        print("media picker did finish with \(items.count) items:")
        items.forEach { print($0) }
        router.focusOnCurrentModule()
    }

    func mediaPickerDidCancel() {
        router.focusOnCurrentModule()
    }

    // MARK: - PhotoLibraryModuleOutput

    func photoLibraryPickerDidFinishWithItems(selectedItems: [PhotoLibraryItem]) {
    }
}
