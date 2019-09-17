import ImageSource
import UIKit

public final class PaparazzoFacade {
    
    private static let imageStorage: ImageStorage = {
        let imageStorage = ImageStorageImpl()
        imageStorage.removeAll()
        return imageStorage
    }()
    
    public static func paparazzoViewController<NavigationController: UINavigationController>(
        theme: PaparazzoUITheme = PaparazzoUITheme(),
        parameters: MediaPickerData = MediaPickerData(),
        onFinish: @escaping ([MediaPickerItem]) -> (),
        onCancel: (() -> ())? = nil)
        -> NavigationController
    {
        let assembly = assemblyFactory(theme: theme).mediaPickerAssembly()
        
        let viewController = assembly.module(
            data: parameters,
            configure: { (module: MediaPickerModule) in
                module.setContinueButtonTitle("Done")
                module.onCancel = { [weak module] in
                    module?.dismissModule()
                    onCancel?()
                }
                module.onFinish = { [weak module] items in
                    module?.dismissModule()
                    onFinish(items)
                }
            }
        )
        
        return NavigationController(rootViewController: viewController)
    }
    
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
        onFinish: @escaping ([MediaPickerItem]) -> (),
        onCancel: (() -> ())? = nil)
        -> NavigationController
    {
        let assembly = assemblyFactory(theme: theme).photoLibraryV2Assembly()
        
        let galleryController = assembly.module(
            data: parameters,
            isMetalEnabled: false,
            isNewFlowPrototype: true,
            configure: { (module: PhotoLibraryV2Module) in
                module.onFinish = { [weak module] result in
                    module?.dismissModule()
                    onFinish(result)
                }
                module.onCancel = { [weak module] in
                    module?.dismissModule()
                    onCancel?()
                }
            }
        )
        
        return NavigationController(rootViewController: galleryController)
    }
    
    private static func assemblyFactory(theme: PaparazzoUITheme) -> AssemblyFactory {
        return AssemblyFactory(theme: theme, imageStorage: imageStorage)
    }
}
