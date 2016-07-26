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
    
    // MARK: - PhotoLibraryModuleInput
    
    var onFinish: ((selectedItems: [PhotoLibraryItem]) -> ())?
    
    func selectItems(items: [PhotoLibraryItem]) {
        // TODO
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        interactor.observeItems { [weak self] items, selectionState in
            
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
                self?.onFinish?(selectedItems: items)
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