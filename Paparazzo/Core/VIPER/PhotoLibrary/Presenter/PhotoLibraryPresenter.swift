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
    
    // MARK: - State
    var shouldScrollToBottomOnFullReload = true
    
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
            guard let strongSelf = self else { return }
            
            // We're showing only non-empty albums
            self?.view?.setAlbums(albums.filter { $0.numberOfItems > 0 }.map(strongSelf.albumCellData))
            
            if strongSelf.interactor.currentAlbum == nil, let album = albums.first {
                self?.selectAlbum(album)
            }
        }
        
        interactor.observeCurrentAlbumEvents { [weak self] event, selectionState in
            guard let strongSelf = self else { return }
            
            switch event {
            case .fullReload(let items):
                self?.view?.setItems(
                    items.map(strongSelf.cellData),
                    scrollToBottom: strongSelf.shouldScrollToBottomOnFullReload,
                    completion: {
                        self?.shouldScrollToBottomOnFullReload = false
                        self?.adjustViewForSelectionState(selectionState)
                        self?.view?.setProgressVisible(false)
                    }
                )
                
            case .incrementalChanges(let changes):
                self?.view?.applyChanges(strongSelf.viewChanges(from: changes), completion: {
                    self?.adjustViewForSelectionState(selectionState)
                })
            }
        }
        
        view?.onPickButtonTap = { [weak self] in
            if let strongSelf = self {
                self?.onFinish?(.selectedItems(strongSelf.interactor.selectedItems))
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
    
    private func albumCellData(for album: PhotoLibraryAlbum) -> PhotoLibraryAlbumCellData {
        return PhotoLibraryAlbumCellData(
            identifier: album.identifier,
            title: album.title ?? localized("Unnamed album"),
            coverImage: album.coverImage,
            onSelect: { [weak self] in
                self?.selectAlbum(album)
                self?.view?.hideAlbumsList()
            }
        )
    }
    
    private func selectAlbum(_ album: PhotoLibraryAlbum) {
        shouldScrollToBottomOnFullReload = true
        interactor.setCurrentAlbum(album)
        view?.setTitle(album.title ?? localized("Unnamed album"))
        view?.selectAlbum(withId: album.identifier)
    }
    
    private func cellData(_ item: PhotoLibraryItem) -> PhotoLibraryItemCellData {
        
        var cellData = PhotoLibraryItemCellData(image: item.image)

        cellData.selected = interactor.isSelected(item)
        
        cellData.onSelectionPrepare = { [weak self] in
            if let selectionState = self?.interactor.prepareSelection() {
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        cellData.onSelect = { [weak self] in
            if let selectionState = self?.interactor.selectItem(item) {
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        cellData.onDeselect = { [weak self] in
            if let selectionState = self?.interactor.deselectItem(item) {
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
