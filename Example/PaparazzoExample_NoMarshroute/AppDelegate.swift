import Paparazzo
import ImageSource
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool
    {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func rootViewController() -> UIViewController {
        
        let exampleController = ExampleViewController()
        
        var mediaPickerItems = [MediaPickerItem]()
        var photoLibraryItems = [PhotoLibraryItem]()
        
        // Show full media picker
        exampleController.onShowMediaPickerButtonTap = { [weak exampleController] in
            
            let viewController = PaparazzoFacade.paparazzoViewController(
                theme: PaparazzoUITheme.appSpecificTheme(),
                parameters: MediaPickerData(
                    items: mediaPickerItems,
                    maxItemsCount: 3
                ),
                onFinish: { images in
                    mediaPickerItems = images
                }
            )
            
            exampleController?.present(viewController, animated: true)
        }
        
        // Show mask cropper
        exampleController.onShowMaskCropperButtonTap = { [weak exampleController] in
            
            guard let pathToImage = Bundle.main.path(forResource: "kitten", ofType: "jpg") else {
                assertionFailure("Oooops. Kitten is lost :(")
                return
            }
            
            let viewController = PaparazzoFacade.maskCropperViewController(
                theme: PaparazzoUITheme.appSpecificTheme(),
                parameters: MaskCropperData(
                    imageSource: LocalImageSource(path: pathToImage)
                ),
                croppingOverlayProvider: CroppingOverlayProvidersFactoryImpl().circleCroppingOverlayProvider(),
                onFinish: { imageSource in
                    print("Cropped image: \(imageSource)")
                }
            )
            
            exampleController?.present(viewController, animated: true, completion: nil)
        }
        
        // Show only photo library
        exampleController.onShowPhotoLibraryButtonTap = { [weak exampleController] in
            
            let viewController = PaparazzoFacade.libraryViewController(
                theme: PaparazzoUITheme.appSpecificTheme(),
                parameters: PhotoLibraryData(
                    selectedItems: photoLibraryItems,
                    maxSelectedItemsCount: 3
                ),
                onFinish: { images in
                    photoLibraryItems = images
                }
            )
            
            exampleController?.present(viewController, animated: true, completion: nil)
        }
        
        return NavigationController(rootViewController: exampleController)
    }
}
