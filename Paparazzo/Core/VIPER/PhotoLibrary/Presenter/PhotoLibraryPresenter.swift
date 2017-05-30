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
    
    var onFinish: ((PhotoLibraryModuleResult) -> ())?
    
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
        
        interactor.observeAuthorizationStatus { [weak self] accessGranted in
            self?.view?.setAccessDeniedViewVisible(!accessGranted)
        }
        
        interactor.observeItems { [weak self] changes, selectionState in
            guard let strongSelf = self else { return }
            
            let hasItems = (changes.itemsAfterChanges.count > 0)
            
            self?.view?.setPickButtonVisible(hasItems)
            
            let animated = (self?.shouldScrollToBottomWhenItemsArrive == false)
            
            self?.view?.applyChanges(strongSelf.viewChanges(from: changes), animated: animated, completion: {
                
                self?.adjustViewForSelectionState(selectionState)
                
                if self?.shouldScrollToBottomWhenItemsArrive == true {
                    self?.view?.scrollToBottom()
                    self?.shouldScrollToBottomWhenItemsArrive = false
                }
            })
        }
        
        view?.setPickButtonEnabled(false)
        
        view?.onPickButtonTap = { [weak self] in
            self?.interactor.selectedItems { items in
                self?.onFinish?(.selectedItems(items))
            }
        }
        
        view?.onCancelButtonTap = { [weak self] in
            self?.onFinish?(.cancelled)
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func adjustViewForSelectionState(_ state: PhotoLibraryItemSelectionState) {
        view?.setDimsUnselectedItems(!state.canSelectMoreItems)
        view?.setCanSelectMoreItems(state.canSelectMoreItems)
        view?.setPickButtonEnabled(state.isAnyItemSelected)
        
        switch state.preSelectionAction {
        case .none:
            break
        case .deselectAll:
            view?.deselectAllItems()
        }
    }
    
    private func cellData(_ item: PhotoLibraryItem) -> PhotoLibraryItemCellData {
        
        var cellData = PhotoLibraryItemCellData(image: item.image)

        cellData.selected = item.selected
        
        cellData.onSelectionPrepare = { [weak self] in
            self?.interactor.prepareSelection { [weak self] selectionState in
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
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
    
    private func viewChanges(from changes: PhotoLibraryChanges) -> PhotoLibraryViewChanges {
        return PhotoLibraryViewChanges(
            removedIndexes: changes.removedIndexes,
            insertedItems: changes.insertedItems.map { (index: $0, cellData: cellData($1)) },
            updatedItems: changes.updatedItems.map { (index: $0, cellData: cellData($1)) },
            movedIndexes: changes.movedIndexes
        )
    }
}
