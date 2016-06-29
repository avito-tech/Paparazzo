import AvitoMediaPicker

final class ExamplePresenter {
    
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
            
            self?.router.showMediaPicker(maxItemsCount: 7) { module in
                
                module.onItemsAdd = { _ in debugPrint("mediaPickerDidAddItems") }
                module.onItemUpdate = { _ in debugPrint("mediaPickerDidUpdateItem") }
                module.onItemRemove = { _ in debugPrint("mediaPickerDidRemoveItem") }
                
                module.onCancel = { [weak self] in
                    self?.router.focusOnCurrentModule()
                }
                
                module.onFinish = { [weak self] items in
                    print("media picker did finish with \(items.count) items:")
                    items.forEach { print($0) }
                    self?.router.focusOnCurrentModule()
                }
            }
        }
        
        view?.onShowPhotoLibraryButtonTap = { [weak self] in
            
            self?.interactor.photoLibraryItems { selectedItems in
            
                self?.router.showPhotoLibrary(maxSelectedItemsCount: 5) { module in
                    
                    module.selectItems(selectedItems)
                    
                    module.onFinish = { items in
                        self?.interactor.setPhotoLibraryItems(selectedItems)
                        self?.router.focusOnCurrentModule()
                    }
                }
            }
        }
    }
}
