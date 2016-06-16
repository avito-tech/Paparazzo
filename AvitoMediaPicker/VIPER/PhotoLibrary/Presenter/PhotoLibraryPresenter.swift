import Foundation

final class PhotoLibraryPresenter: PhotoLibraryModuleInput {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryInteractor
    private let router: PhotoLibraryRouter
    
    weak var moduleOutput: PhotoLibraryModuleOutput?
    
    weak var view: PhotoLibraryViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Flags
    
    private var shouldScrollToBottomWhenItemsArrive = true
    
    // MARK: - Init
    
    init(interactor: PhotoLibraryInteractor, router: PhotoLibraryRouter) {
        self.interactor = interactor
        self.router = router
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
        
        view?.onPickButtonTap = { [weak self] in
            self?.interactor.selectedItems { items in
                self?.moduleOutput?.photoLibraryPickerDidFinishWithItems(items)
            }
        }
    }
    
    private func setCellsDataFromItems(items: [PhotoLibraryItem]) {
        view?.setCellsData(items.map(cellData))
    }
    
    private func adjustViewForSelectionState(state: PhotoLibraryItemSelectionState) {
        view?.setDimsUnselectedItems(state.isAnyItemSelected)
        view?.setCanSelectMoreItems(state.canSelectMoreItems)
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