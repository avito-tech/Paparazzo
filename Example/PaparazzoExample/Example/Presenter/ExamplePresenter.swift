import Paparazzo
import ImageSource

final class ExamplePresenter {
    
    // MARK: - Dependencies
    
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
    
    private var items: [MediaPickerItem] = []
    
    private let cropCanvasSize = CGSize(width: 1280, height: 960)
    
    // MARK: - Private
    
    private let croppingOverlayProvidersFactory = Paparazzo.CroppingOverlayProvidersFactoryImpl()
    
    private func setUpView() {
        
        view?.setMediaPickerButtonTitle("Media Picker")
        view?.setMaskCropperButtonTitle("Mask Cropper")
        view?.setPhotoLibraryButtonTitle("Photo Library")
        
        view?.onShowMediaPickerButtonTap = { [weak self] in
            self?.interactor.remoteItems { remoteItems in
                self?.showMediaPicker(remoteItems: remoteItems)
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
        
        view?.onMaskCropperButtonTap = { [weak self] in
            self?.showMaskCropperCamera()
        }
    }
    
    func showMaskCropperCamera() {
        let data = MediaPickerData(
            items: items,
            selectedItem: nil,
            maxItemsCount: 1,
            cropEnabled: true,
            cropCanvasSize: cropCanvasSize,
            initialActiveCameraType: .front
        )
        
        self.router.showMediaPicker(
            data: data,
            configure: { module in
                weak var module = module
                module?.setContinueButtonVisible(false)
                module?.setCropMode(.custom(croppingOverlayProvidersFactory.circleCroppingOverlayProvider()))
                module?.onCancel = {
                    module?.dismissModule()
                }
                module?.onFinish = { items in
                    module?.dismissModule()
                }
            }
        )
    }
    
    private func showMaskCropperIn(rootModule: MediaPickerModule?, photo: MediaPickerItem) {
        
        let data = MaskCropperData(
            imageSource: photo.image,
            cropCanvasSize: cropCanvasSize
        )
        router.showMaskCropper(
            data: data,
            croppingOverlayProvider: croppingOverlayProvidersFactory.heartShapeCroppingOverlayProvider(),
            configure: { module in
                weak var module = module
                module?.onDiscard = {
                    module?.dismissModule()
                }
                module?.onConfirm = { _ in
                    rootModule?.dismissModule()
                }
        })
    }
    
    func showMediaPicker(remoteItems: [MediaPickerItem]) {
        
        var items = self.items
        items.append(contentsOf: remoteItems)
        
        let data = MediaPickerData(
            items: items,
            selectedItem: items.last,
            maxItemsCount: 20,
            cropEnabled: true,
            cropCanvasSize: cropCanvasSize
        )
        
        self.router.showMediaPicker(
            data: data,
            configure: { [weak self] module in
                self?.configureMediaPicker(module: module)
            }
        )
    }
    
    func configureMediaPicker(module: MediaPickerModule) {
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
            self.items = items
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
