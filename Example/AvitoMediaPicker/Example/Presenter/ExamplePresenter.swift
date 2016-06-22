import AvitoMediaPicker

final class ExamplePresenter: MediaPickerModuleOutput {
    
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
            self?.router.showMediaPicker(maxItemsCount: 5, output: strongSelf)
        }
        
        view?.onShowPhotoLibraryButtonTap = { [weak self] in
            self?.showPhotoLibrary()
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
    
    // MARK: - Private
    
    func showPhotoLibrary() {
        interactor.photoLibraryItems { [weak self] selectedItems in
            self?.router.showPhotoLibrary { module in
                module.setMaxItemsCount(5)
                module.selectItems(selectedItems)
                module.onFinish = { items in
                    self?.interactor.setPhotoLibraryItems(selectedItems)
                    self?.router.focusOnCurrentModule()
                }
            }
        }
    }
}
