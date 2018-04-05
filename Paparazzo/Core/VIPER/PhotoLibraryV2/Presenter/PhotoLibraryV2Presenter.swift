import Foundation

final class PhotoLibraryV2Presenter: PhotoLibraryV2Module {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryV2Interactor
    private let router: PhotoLibraryV2Router
    
    weak var view: PhotoLibraryV2ViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
            }
        }
    }
    
    // MARK: - State
    var shouldScrollToBottomOnFullReload = true
    
    // MARK: - Init
    
    init(interactor: PhotoLibraryV2Interactor, router: PhotoLibraryV2Router) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - PhotoLibraryModule
    
    var onFinish: ((PhotoLibraryV2ModuleResult) -> ())?
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
    func setContinueButtonTitle(_ title: String) {
        continueButtonTitle = title
        view?.setContinueButtonTitle(title)
    }
    
    // MARK: - Private
    private var continueButtonTitle: String?
    
    private func setUpView() {
        
        view?.setContinueButtonTitle(continueButtonTitle ?? localized("Continue"))
        
        view?.setTitleVisible(false)
        
        view?.setPlaceholderState(.hidden)
        
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
            let albums = albums.filter { $0.numberOfItems > 0 }
            
            self?.view?.setAlbums(albums.map(strongSelf.albumCellData))
            
            if let currentAlbum = strongSelf.interactor.currentAlbum, albums.contains(currentAlbum) {
                self?.adjustView(for: currentAlbum)  // title might have been changed
            } else if let album = albums.first {
                self?.selectAlbum(album)
            } else {
                self?.view?.setTitleVisible(false)
                self?.view?.setPlaceholderState(.visible(title: localized("No photos")))
                self?.view?.setProgressVisible(false)
            }
        }
        
        interactor.observeCurrentAlbumEvents { [weak self] event, selectionState in
            guard let strongSelf = self else { return }
            
            var needToShowPlaceholder: Bool
            
            switch event {
            case .fullReload(let items):
                needToShowPlaceholder = items.isEmpty
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
                needToShowPlaceholder = changes.itemsAfterChanges.isEmpty
                self?.view?.applyChanges(strongSelf.viewChanges(from: changes), completion: {
                    self?.adjustViewForSelectionState(selectionState)
                })
            }
            
            self?.view?.setPlaceholderState(
                needToShowPlaceholder ? .visible(title: localized("Album is empty")) : .hidden
            )
        }
        
        view?.onContinueButtonTap = { [weak self] in
            if let strongSelf = self {
                self?.onFinish?(.selectedItems(strongSelf.interactor.selectedItems))
            }
        }
        
        view?.onCloseButtonTap = { [weak self] in
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
        adjustView(for: album)
    }
    
    private func adjustView(for album: PhotoLibraryAlbum) {
        view?.setTitle(album.title ?? localized("Unnamed album"))
        view?.setTitleVisible(true)
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
    
    private func cameraCellData(completion: @escaping (_ cellData: PhotoLibraryCameraCellData?) -> ()) {
        interactor.getOutputParameters { parameters in
            guard let parameters = parameters else {
                completion(nil)
                return
            }
            let cellData = PhotoLibraryCameraCellData(
                parameters: parameters,
                onTap: {
                    print("ololo")
                }
            )
            
            completion(cellData)
        }
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
