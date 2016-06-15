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
    
    // MARK: - Init
    
    init(interactor: PhotoLibraryInteractor, router: PhotoLibraryRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        interactor.observeItems { [weak self] items in
            self?.setCellsDataFromItems(items)
        }
        
        view?.onPickButtonTap = { [weak self] in
            self?.interactor.selectedItems { items, canSelectMoreItems in
                self?.moduleOutput?.photoLibraryPickerDidFinishWithItems(items)
            }
        }
    }
    
    private func setCellsDataFromItems(items: [PhotoLibraryItem]) {
        view?.setCellsData(items.map(cellData))
    }
    
    private func cellData(item: PhotoLibraryItem) -> PhotoLibraryItemCellData {
        
        var cellData = PhotoLibraryItemCellData(image: item.image)

        cellData.selected = item.selected
        
        cellData.onSelect = { [weak self] in
            self?.interactor.selectItem(item) { canSelectMoreItems in
                self?.view?.setCanSelectMoreItems(canSelectMoreItems)
            }
        }
        
        cellData.onDeselect = { [weak self] in
            self?.interactor.deselectItem(item) { canSelectMoreItems in
                self?.view?.setCanSelectMoreItems(canSelectMoreItems)
            }
        }
        
        return cellData
    }
}