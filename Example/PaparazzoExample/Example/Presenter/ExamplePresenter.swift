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
        view?.onViewDidLoad = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view?.setItems(strongSelf.exampleViewItems())
        }
    }
    
    func showMaskCropperCamera() {
        let data = MediaPickerData(
            items: items,
            selectedItem: nil,
            maxItemsCount: 1,
            cropEnabled: true,
            hapticFeedbackEnabled: true,
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
    
    private var recognitionHandler: ScannerOutputHandler?
    func showScanner() {
        
        if #available(iOS 11.0, *) {
            let recognitionHandler = (self.recognitionHandler as? ObjectsRecognitionStreamHandler) ?? ObjectsRecognitionStreamHandler()
            if self.recognitionHandler == nil {
                self.recognitionHandler = recognitionHandler
            }
            
            let data = ScannerData(
                initialActiveCameraType: .back,
                cameraCaptureOutputHandlers: [recognitionHandler]
            )
            
            self.router.showScanner(
                data: data,
                configure: { module in
                    weak var module = module
                    module?.onCancel = {
                        module?.dismissModule()
                    }
                    module?.onFinish = {
                        module?.dismissModule()
                    }
                    
                    recognitionHandler.onRecognize = { label in
                        module?.showInfoMessage(label, timeout: 3)
                    }
                }
            )   
        }
    }
    
    private func showPhotoLibraryV2(newFlow: Bool) {
        interactor.photoLibraryItems { [weak self] items in
            let data = MediaPickerData(
                maxItemsCount: 5,
                cropEnabled: true,
                autocorrectEnabled: true,
                hapticFeedbackEnabled: true,
                cropCanvasSize: self?.cropCanvasSize ?? .zero
            )
            self?.router.showPhotoLibraryV2(
                mediaPickerData: data,
                selectedItems: items,
                isNewFlowPrototype: newFlow,
                configure: { module in
                    weak var weakModule = module
                    module.setContinueButtonPlacement(.bottom)
                    module.onFinish = { result in
                        print("onFinish")
                        weakModule?.setContinueButtonStyle(.spinner)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            weakModule?.dismissModule()
                        }
                    }
                    module.onCancel = {
                        weakModule?.dismissModule()
                    }
                }
            )
        }
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
            autocorrectionFilters: [AutoAdjustmentFilter()],
            selectedItem: items.last,
            maxItemsCount: 5,
            cropEnabled: true,
            autocorrectEnabled: true,
            hapticFeedbackEnabled: true,
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

        module.setCameraTitle("Please take a photo")
        let textHint = "Сфотографируйте предмет,\nчтобы найти похожий на Avito"
        module.setCameraHint(data: CameraHintData(title: textHint, delay: 3))
        
        module.onItemsAdd = { _, _ in debugPrint("mediaPickerDidAddItems") }
        module.onItemUpdate = { _, _ in debugPrint("mediaPickerDidUpdateItem") }
        module.onItemRemove = { _, _ in debugPrint("mediaPickerDidRemoveItem") }
        
        module.onItemAutocorrect = { _, isAutocorrected, _ in
            debugPrint("mediaPickerDidAutocorrectItem: \(isAutocorrected)")
        }
        
        module.setContinueButtonTitle("Done")
        module.setContinueButtonPlacement(.bottom)
        
        module.onCancel = { [weak module] in
            module?.dismissModule()
        }
        
        module.onContinueButtonTap = { [weak module] in
            module?.setContinueButtonStyle(.spinner)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                module?.finish()
            }
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
                deliveryMode: .best,
                needsMetadata: true
            )
            
            items.first?.image.requestImage(options: options) { (result: ImageRequestResult<UIImage>) in
                let data = result.image.flatMap { $0.pngData() }
                let url = URL(fileURLWithPath: NSTemporaryDirectory() + "/crop_test2.jpg")
                try! data?.write(to: url, options: [.atomic])
            }
        }
    }
    
    // MARK: - ExampleView Items
    
    private func exampleViewItems() -> [ExampleViewItem] {
        return [
            photoLibraryV2NewFlowItem(),
            photoLibraryV2Item(),
            photoLibraryItem(),
            mediaPickerItem(),
            maskCropperItem(),
            scannerItem()
        ]
    }
    
    private func mediaPickerItem() -> ExampleViewItem {
        return ExampleViewItem(
            title: "Media Picker",
            onTap: { [weak self] in
                self?.interactor.remoteItems { remoteItems in
                    self?.showMediaPicker(remoteItems: remoteItems)
                }
            }
        )
    }
    
    private func maskCropperItem() -> ExampleViewItem {
        return ExampleViewItem(
            title: "Mask Cropper",
            onTap: { [weak self] in
                self?.showMaskCropperCamera()
            }
        )
    }
    
    private func photoLibraryItem() -> ExampleViewItem {
        return ExampleViewItem(
            title: "Photo Library v1",
            onTap: { [weak self] in
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
        )
    }
    
    private func photoLibraryV2Item() -> ExampleViewItem {
        return ExampleViewItem(
            title: "Photo Library v2 — Old flow",
            onTap: { [weak self] in
                self?.showPhotoLibraryV2(newFlow: false)
            }
        )
    }
    
    private func photoLibraryV2NewFlowItem() -> ExampleViewItem {
        return ExampleViewItem(
            title: "Photo Library v2 — New flow",
            onTap: { [weak self] in
                self?.showPhotoLibraryV2(newFlow: true)
            }
        )
    }
    
    private func scannerItem() -> ExampleViewItem {
        return ExampleViewItem(
            title: "Scanner",
            onTap: { [weak self] in
                self?.showScanner()
            }
        )
    }
}
