import UIKit
import Marshroute
import AvitoMediaPicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MediaPickerModuleOutput {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        var colors = MediaPickerColors()
        // Раскомментить для проверки кастомизации цветов модуля:
//        colors.shutterButtonColor = .redColor()
//        colors.mediaRibbonSelectionColor = .greenColor()
//        colors.photoLibraryItemSelectionColor = .yellowColor()
        
        window?.rootViewController = MarshrouteFacade().navigationController(NavigationController()) { routerSeed in
            
            let assemblyFactory = AssemblyFactory(colors: colors)
            let photoPickerAssembly = assemblyFactory.mediaPickerAssembly()
            
            return photoPickerAssembly.viewController(
                maxItemsCount: 5,
                moduleOutput: self,
                routerSeed: routerSeed
            )
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

