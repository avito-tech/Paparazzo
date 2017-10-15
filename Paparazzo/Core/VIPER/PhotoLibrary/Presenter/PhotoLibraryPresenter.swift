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
    
    private var shouldScrollToBottomAfterFullReload = true
    
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
        
        view?.setTitle(localized("All photos"))
        
        view?.setAccessDeniedTitle(localized("To pick photo from library"))
        view?.setAccessDeniedMessage(localized("Allow %@ to access your photo library", appName()))
        view?.setAccessDeniedButtonTitle(localized("Allow access to photo library"))
        
        view?.setProgressVisible(true)
        
        interactor.observeAuthorizationStatus { [weak self] accessGranted in
            self?.view?.setAccessDeniedViewVisible(!accessGranted)
            
            if !accessGranted {
                self?.view?.setProgressVisible(false)
            }
        }
        
        interactor.observeAlbums { [weak self] albums in
            
            if let album = albums.first {
                self?.setUpObservingOfItems(in: album)
                self?.view?.setTitle(album.title ?? localized("Unnamed album"))
            }
            
            self?.view?.setAlbums(albums.map { album in
                PhotoLibraryAlbumCellData(
                    title: album.title ?? localized("Unnamed album"),
                    coverImage: album.coverImage,
                    onSelect: {
                        self?.view?.setTitle(album.title ?? localized("Unnamed album"))
                        self?.view?.hideAlbumsList()
                        self?.shouldScrollToBottomAfterFullReload = true
                        self?.setUpObservingOfItems(in: album)
                    }
                )
            })
        }
        
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
        
        view?.onTitleTap = { [weak self] in
            self?.view?.toggleAlbumsList()
        }
        
        view?.onDimViewTap = { [weak self] in
            self?.view?.hideAlbumsList()
        }
    }
    
    private func setUpObservingOfItems(in album: PhotoLibraryAlbum) {
        interactor.observeEvents(in: album) { [weak self] event, selectionState in
            guard let strongSelf = self else { return }
            
            self?.view?.setProgressVisible(false)
            
            switch event {
            case .fullReload(let items):
                self?.view?.setItems(
                    items.map(strongSelf.cellData),
                    scrollToBottom: strongSelf.shouldScrollToBottomAfterFullReload,
                    completion: {
                        self?.shouldScrollToBottomAfterFullReload = false
                        self?.adjustViewForSelectionState(selectionState)
                    }
                )
                
            case .changes(let changes):
                self?.view?.applyChanges(strongSelf.viewChanges(from: changes), completion: {
                    self?.adjustViewForSelectionState(selectionState)
                })
            }
        }
    }
    
    private func appName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    private func adjustViewForSelectionState(_ state: PhotoLibraryItemSelectionState) {
        view?.setDimsUnselectedItems(!state.canSelectMoreItems)
        view?.setCanSelectMoreItems(state.canSelectMoreItems)
        
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
