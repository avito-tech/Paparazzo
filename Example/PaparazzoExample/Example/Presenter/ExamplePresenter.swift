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
        view?.setPhotoLibraryV2ButtonTitle("Photo Library version 2")
        view?.setScannerButtonTitle("Scanner")
        
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
        
        view?.onShowPhotoLibraryV2ButtonTap = { [weak self] in
            self?.interactor.photoLibraryItems { items in
                let data = MediaPickerData(
                    maxItemsCount: 20,
                    cropEnabled: true,
                    autocorrectEnabled: true,
                    hapticFeedbackEnabled: true,
                    cropCanvasSize: self?.cropCanvasSize ?? .zero
                )
                self?.router.showPhotoLibraryV2(
                    mediaPickerData: data,
                    selectedItems: items,
                    maxSelectedItemsCount: 5)
                { module in
                    weak var weakModule = module
                    module.setContinueButtonPlacement(.bottom)
                    module.onFinish = { result in
                        weakModule?.dismissModule()
                    }
                    module.onCancel = {
                        weakModule?.dismissModule()
                    }
                }
            }
        }
        
        view?.onShowMaskCropperButtonTap = { [weak self] in
            self?.showMaskCropperCamera()
        }
        
        view?.onShowScannerButtonTap = { [weak self] in
            self?.showScanner()
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
            maxItemsCount: 20,
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
    
}
