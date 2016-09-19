import UIKit
import Marshroute
import AvitoMediaPicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
//        print(UIFont.fontNamesForFamilyName("Latoto"))
        debugPrint(NSTemporaryDirectory())
        
        cleanTemporaryDirectory()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = MarshrouteFacade().navigationController(NavigationController()) { routerSeed in
            ExampleAssemblyImpl().viewController(routerSeed: routerSeed)
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

