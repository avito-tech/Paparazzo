import UIKit
import Marshroute
import AvitoMediaPicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MediaPickerModuleOutput {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = MarshrouteFacade().navigationController(NavigationController()) { routerSeed in
            ExampleAssemblyImpl().viewController(routerSeed: routerSeed)
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: - PhotoPickerModuleOutput

    func photoPickerDidAddItem(item: MediaPickerItem) {
    }

    func photoPickerDidUpdateItem(item: MediaPickerItem) {
    }

    func photoPickerDidRemoveItem(item: MediaPickerItem) {
    }

    func photoPickerDidFinish() {
    }

    func photoPickerDidCancel() {
    }
}

