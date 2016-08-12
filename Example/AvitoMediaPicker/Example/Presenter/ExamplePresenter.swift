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
            
            let items = self?.items ?? []
            
            self?.router.showMediaPicker(items: items, selectedItem: items.last, maxItemsCount: 5) { module in
                
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
                    
                    items.first?.image.fullResolutionImageData { data in
                        debugPrint("first item data size = \(data?.length ?? 0)")
                    }
                }
            }
        }
        
        view?.onShowPhotoLibraryButtonTap = { [weak self] in
            self?.interactor.photoLibraryItems { items in
                self?.router.showPhotoLibrary(selectedItems: items, maxSelectedItemsCount: 5) { module in
                    weak var weakModule = module
                    module.onFinish = { result in
                        weakModule?.dismissModule()
                        
                        switch result {
                        case .SelectedItems(let items):
                            self?.interactor.setPhotoLibraryItems(items)
                        case .Cancelled:
                            break
                        }
                    }
                }
            }
        }
    }
}
