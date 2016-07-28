import UIKit
import Marshroute
import AvitoMediaPicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        print(UIFont.fontNamesForFamilyName("Latoto"))
        debugPrint(NSTemporaryDirectory())
        
        cleanTemporaryDirectory()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = MarshrouteFacade().navigationController(NavigationController()) { routerSeed in
            ExampleAssemblyImpl().viewController(routerSeed: routerSeed)
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func cleanTemporaryDirectory() {
        
        let fileManager = NSFileManager.defaultManager()
        let dirPath = NSTemporaryDirectory()
        
        if let enumerator = fileManager.enumeratorAtPath(dirPath) {
            while let filename = enumerator.nextObject() as? String {
                let path = (dirPath as NSString).stringByAppendingPathComponent(filename)
                do {
                    try fileManager.removeItemAtPath(path)
                } catch {}
            }
        }
    }
}

