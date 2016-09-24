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
    
    private var items: [MediaPickerItem] = [
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "http://fonday.ru/images/tmp/16/7/original/16710fBjLzqnJlMXhoFHAG.jpg")!), source: .Camera),
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "http://www.velvet.by/files/userfiles/19083/ekrk.jpg")!), source: .Camera),
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "https://img3.goodfon.ru/original/1920x1080/7/3e/koshki-milye-kotiki.jpg")!), source: .Camera),
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "http://www.catgallery.ru/kototeka/wp-content/uploads/2015/04/Foto-podborka-kosoglazyih-kotikov-3.jpg")!), source: .Camera),
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "https://i.ytimg.com/vi/IRSsqnJPBrs/maxresdefault.jpg")!), source: .Camera),
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "http://fonday.ru/images/tmp/16/7/original/16710fBjLzqnJlMXhoFHAG.jpg")!), source: .Camera),
//        MediaPickerItem(image: RemoteImageSource(url: NSURL(string: "http://www.velvet.by/files/userfiles/19083/ekrk.jpg")!), source: .Camera)
    ]
    
    private func setUpView() {
        
        view?.onShowMediaPickerButtonTap = { [weak self] in
            
            let items = self?.items ?? []
            let cropCanvasSize = CGSize(width: 1280, height: 960)
            
            self?.router.showMediaPicker(items: items, selectedItem: items.last, maxItemsCount: 20, cropCanvasSize: cropCanvasSize) { module in
                
                module.onItemsAdd = { _ in debugPrint("mediaPickerDidAddItems") }
                module.onItemUpdate = { _ in debugPrint("mediaPickerDidUpdateItem") }
                module.onItemRemove = { _ in debugPrint("mediaPickerDidRemoveItem") }
                
                module.setContinueButtonTitle("Готово")
                
                module.onCancel = { [weak module] in
                    module?.dismissModule()
                }
                
                module.onFinish = { [weak module] items in
                    debugPrint("media picker did finish with \(items.count) items:")
                    items.forEach { debugPrint($0) }
                    self?.items = items
                    module?.dismissModule()
                    
                    items.first?.image.fullResolutionImageData { data in
                        debugPrint("first item data size = \(data?.count ?? 0)")
                        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "/crop_test1.jpg")
                        try! data?.write(to: url, options: [.atomic])
                    }
                    
                    let options = ImageRequestOptions(
                        size: .fitSize(CGSize(width: 1000, height: 1000)),
                        deliveryMode: .best
                    )
                    
                    items.first?.image.requestImage(options: options) { (result: ImageRequestResult<UIImage>) in
                        let data = result.image.flatMap { UIImagePNGRepresentation($0) }
                        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "/crop_test2.jpg")
                        try! data?.write(to: url, options: [.atomic])
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
                        case .selectedItems(let items):
                            self?.interactor.setPhotoLibraryItems(items)
                        case .cancelled:
                            break
                        }
                    }
                }
            }
        }
    }
}
