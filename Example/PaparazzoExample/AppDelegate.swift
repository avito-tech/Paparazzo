import UIKit
import Marshroute
import Paparazzo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil)
        -> Bool
    {
        debugPrint(NSTemporaryDirectory())
        
        cleanTemporaryDirectory()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let imageStorage = ImageStorageImpl()
        imageStorage.removeAll()
        let mediaPickerAssemblyFactory = Paparazzo.MarshrouteAssemblyFactory(
            theme: PaparazzoUITheme.appSpecificTheme(),
            imageStorage: imageStorage
        )
        let exampleAssembly = ExampleAssemblyImpl(mediaPickerAssemblyFactory: mediaPickerAssemblyFactory)
        
        window?.rootViewController = MarshrouteFacade().navigationController(NavigationController()) { routerSeed in
            exampleAssembly.viewController(routerSeed: routerSeed)
        }
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func cleanTemporaryDirectory() {
        
        let fileManager = FileManager.default
        let dirPath = NSTemporaryDirectory()
        
        if let enumerator = fileManager.enumerator(atPath: dirPath) {
            while let filename = enumerator.nextObject() as? String {
                let path = (dirPath as NSString).appendingPathComponent(filename)
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {}
            }
        }
    }
}

