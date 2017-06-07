import Paparazzo
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func rootViewController() -> UIViewController {
        
        let assemblyFactory = Paparazzo.AssemblyFactory(theme: PaparazzoUITheme.appSpecificTheme())
        
        let exampleController = ExampleViewController()
        
        let itemProvider = ItemProvider()
        
        // Show full media picker
        exampleController.onShowMediaPickerButtonTap = { [weak exampleController] in
            
            let assembly = assemblyFactory.mediaPickerAssembly()
            
            let mediaPickerController = assembly.module(
                items: itemProvider.remoteItems(),
                selectedItem: nil,
                maxItemsCount: 20,
                cropEnabled: true,
                cropCanvasSize: CGSize(width: 1280, height: 960),
                configure: { module in
                    weak var module = module
                    
                    module?.setContinueButtonTitle("Готово")
                    
                    module?.onCancel = {
                        module?.dismissModule()
                    }
                    module?.onFinish = { _ in
                        module?.dismissModule()
                    }
                }
            )
            
            exampleController?.navigationController?.pushViewController(mediaPickerController, animated: true)
        }
        
        // Show only photo library
        exampleController.onShowPhotoLibraryButtonTap = { [weak exampleController] in
            
            let assembly = assemblyFactory.photoLibraryAssembly()
            
            let galleryController = assembly.module(
                selectedItems: [],
                maxSelectedItemsCount: 5,
                configure: { module in
                    weak var module = module
                    module?.onFinish = { _ in
                        module?.dismissModule()
                    }
                }
            )
            
            let navigationController = UINavigationController(rootViewController: galleryController)
            
            exampleController?.present(navigationController, animated: true, completion: nil)
        }
        
        return NavigationController(rootViewController: exampleController)
    }
}
