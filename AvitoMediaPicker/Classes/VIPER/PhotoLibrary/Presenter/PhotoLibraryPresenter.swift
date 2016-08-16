import Foundation

final class PhotoLibraryPresenter: PhotoLibraryModule {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryInteractor
    private let router: PhotoLibraryRouter
    
    weak var view: PhotoLibraryViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
            }
        }
    }
    
    // MARK: - Flags
    
    private var shouldScrollToBottomWhenItemsArrive = true
    
    // MARK: - Init
    
    init(interactor: PhotoLibraryInteractor, router: PhotoLibraryRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - PhotoLibraryModule
    
    var onFinish: (PhotoLibraryModuleResult -> ())?
    
    func focusOnModule() {
        router.focusOnCurrentModule()
    }
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setTitle("Все фотографии")
        view?.setDoneButtonTitle("Выбрать")
        view?.setCancelButtonTitle("Отменить")
        
        view?.setAccessDeniedTitle("Чтобы выбрать фото из галереи")
        view?.setAccessDeniedMessage("Разрешите доступ приложению Avito к вашим фотографиям")
        view?.setAccessDeniedButtonTitle("Разрешить доступ к галерее")
        
        interactor.authorizationStatus { [weak self] accessGranted in
            self?.view?.setAccessDeniedViewVisible(!accessGranted)
        }
        
        interactor.observeItems { [weak self] items, selectionState in
            
            if items.count > 0 {
                self?.view?.setAccessDeniedViewVisible(false)
            }
            
            self?.setCellsDataFromItems(items)
            self?.adjustViewForSelectionState(selectionState)
            
            if self?.shouldScrollToBottomWhenItemsArrive == true {
                self?.view?.scrollToBottom()
                self?.shouldScrollToBottomWhenItemsArrive = false
            }
        }
        
        view?.setPickButtonEnabled(false)
        
        view?.onPickButtonTap = { [weak self] in
            self?.interactor.selectedItems { items in
                self?.onFinish?(.SelectedItems(items))
            }
        }
        
        view?.onCancelButtonTap = { [weak self] in
            self?.onFinish?(.Cancelled)
        }
        
        view?.onAccessDeniedButtonTap = { [weak self] in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    private func setCellsDataFromItems(items: [PhotoLibraryItem]) {
        view?.setCellsData(items.map(cellData))
    }
    
    private func adjustViewForSelectionState(state: PhotoLibraryItemSelectionState) {
        view?.setDimsUnselectedItems(!state.canSelectMoreItems)
        view?.setCanSelectMoreItems(state.canSelectMoreItems)
        view?.setPickButtonEnabled(state.isAnyItemSelected)
    }
    
    private func cellData(item: PhotoLibraryItem) -> PhotoLibraryItemCellData {
        
        var cellData = PhotoLibraryItemCellData(image: item.image)

        cellData.selected = item.selected
        
        cellData.onSelect = { [weak self] in
            self?.interactor.selectItem(item) { selectionState in
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        cellData.onDeselect = { [weak self] in
            self?.interactor.deselectItem(item) { selectionState in
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        return cellData
    }
}