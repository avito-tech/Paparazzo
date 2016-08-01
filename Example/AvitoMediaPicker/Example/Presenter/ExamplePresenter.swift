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
    
    private var items = [MediaPickerItem]()
    
    private func setUpView() {
        
        view?.onShowMediaPickerButtonTap = { [weak self] in
            
            self?.router.showMediaPicker(maxItemsCount: 20) { module in
                
                module.onItemsAdd = { _ in debugPrint("mediaPickerDidAddItems") }
                module.onItemUpdate = { _ in debugPrint("mediaPickerDidUpdateItem") }
                module.onItemRemove = { _ in debugPrint("mediaPickerDidRemoveItem") }
                
                module.onCancel = { [weak module] in
                    module?.dismissModule()
                }
                
                module.onFinish = { [weak module] items in
                    debugPrint("media picker did finish with \(items.count) items:")
                    items.forEach { debugPrint($0) }
                    self?.items = items
                    module?.dismissModule()
                }
                
                if let items = self?.items {
                    module.setItems(items, selectedItem: items.last)
                }
            }
        }
        
        view?.onShowPhotoLibraryButtonTap = { [weak self] in
            
            self?.interactor.photoLibraryItems { selectedItems in
            
                self?.router.showPhotoLibrary(maxSelectedItemsCount: 5) { module in
                    
                    module.selectItems(selectedItems)
                    
                    module.onFinish = { [weak module] items in
                        self?.interactor.setPhotoLibraryItems(selectedItems)
                        module?.dismissModule()
                    }
                }
            }
        }
    }
}
