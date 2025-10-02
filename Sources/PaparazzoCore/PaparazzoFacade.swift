import ImageSource
import UIKit

public final class PaparazzoFacade {
    
    private static let imageStorage: ImageStorage = {
        let imageStorage = ImageStorageImpl()
        imageStorage.removeAll()
        return imageStorage
    }()
    
    public static func maskCropperViewController<NavigationController: UINavigationController>(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        parameters: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        onFinish: @escaping (ImageSource) -> (),
        onCancel: (() -> ())? = nil)
        -> NavigationController
    {
        let assembly = assemblyFactory(theme: theme).maskCropperAssembly()
        
        let viewController = assembly.module(
            data: parameters,
            croppingOverlayProvider: croppingOverlayProvider,
            configure: { (module: MaskCropperModule) in
                module.onConfirm = { [weak module] imageSource in
                    module?.dismissModule()
                    onFinish(imageSource)
                }
                module.onDiscard = { [weak module] in
                    module?.dismissModule()
                    onCancel?()
                }
            }
        )
        
        return NavigationController(rootViewController: viewController)
    }
    
    public static func libraryViewController<NavigationController: UINavigationController>(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        parameters: PhotoLibraryData = PhotoLibraryData(),
        onFinish: @escaping ([PhotoLibraryItem]) -> (),
        onCancel: (() -> ())? = nil)
        -> NavigationController
    {
        let assembly = assemblyFactory(theme: theme).photoLibraryAssembly()
        
        let galleryController = assembly.module(
            data: parameters,
            configure: { (module: PhotoLibraryModule) in
                module.onFinish = { [weak module] result in
                    module?.dismissModule()
                    
                    switch result {
                    case .selectedItems(let images):
                        onFinish(images)
                    case .cancelled:
                        onCancel?()
                    }
                }
            }
        )
        
        return NavigationController(rootViewController: galleryController)
    }
    
    public static func libraryV2ViewController<NavigationController: UINavigationController>(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        parameters: PhotoLibraryV2Data,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isRedesignedMediaPickerEnabled: Bool,
        onFinish: @escaping ([MediaPickerItem]) -> (),
        onCancel: (() -> ())? = nil,
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> NavigationController {
        let assembly = assemblyFactory(theme: theme).photoLibraryV2Assembly()
        
        let galleryController = assembly.module(
            data: parameters,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isRedesignedMediaPickerEnabled: isRedesignedMediaPickerEnabled,
            isNewFlowPrototype: true,
            cameraType: .cameraV3,
            configure: { (module: PhotoLibraryV2Module) in
                module.onFinish = { [weak module] result in
                    module?.dismissModule()
                    onFinish(result)
                }
                module.onCancel = { [weak module] in
                    module?.dismissModule()
                    onCancel?()
                }
            },
            onCameraV3InitializationMeasurementStart: onCameraV3InitializationMeasurementStart, 
            onCameraV3InitializationMeasurementStop: onCameraV3InitializationMeasurementStop,
            onCameraV3DrawingMeasurementStart: onCameraV3DrawingMeasurementStart, 
            onCameraV3DrawingMeasurementStop: onCameraV3DrawingMeasurementStop
        )
        
        return NavigationController(rootViewController: galleryController)
    }
    
    public static func libraryV3ViewController<NavigationController: UINavigationController>(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        parameters: PhotoLibraryV3Data,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        isRedesignedMediaPickerEnabled: Bool,
        onFinish: @escaping ([MediaPickerItem]) -> (),
        onCancel: (() -> ())? = nil,
        onCameraV3InitializationMeasurementStart: (() -> ())?,
        onCameraV3InitializationMeasurementStop: (() -> ())?,
        onCameraV3DrawingMeasurementStart: (() -> ())?,
        onCameraV3DrawingMeasurementStop: (() -> ())?
    ) -> NavigationController {
        let assembly = assemblyFactory(theme: theme).photoLibraryV3Assembly()
        
        let galleryController = assembly.module(
            data: parameters,
            cameraType: .cameraV3,
            isPaparazzoImageUpdaingFixEnabled: isPaparazzoImageUpdaingFixEnabled,
            isRedesignedMediaPickerEnabled: isRedesignedMediaPickerEnabled,
            configure: { (module: PhotoLibraryV3Module) in
                module.onFinish = { [weak module] result in
                    module?.dismissModule()
                    onFinish(result)
                }
                module.onCancel = { [weak module] in
                    module?.dismissModule()
                    onCancel?()
                }
            },
            onCameraV3InitializationMeasurementStart: onCameraV3InitializationMeasurementStart,
            onCameraV3InitializationMeasurementStop: onCameraV3InitializationMeasurementStop,
            onCameraV3DrawingMeasurementStart: onCameraV3DrawingMeasurementStart,
            onCameraV3DrawingMeasurementStop: onCameraV3DrawingMeasurementStop
        )
        
        return NavigationController(rootViewController: galleryController)
    }
    
    private static func assemblyFactory(
        theme: PaparazzoUITheme
    ) -> AssemblyFactory {
        return AssemblyFactory(
            theme: theme,
            imageStorage: imageStorage
        )
    }
}
