import Paparazzo
import UIKit

final class ViewController: UIViewController {
    
    private var photos = [MediaPickerItem]()
    
    private func updateUI() {
        imageView.setImage(fromSource: photos.first?.image)
    }
    
    // MARK: - Outlets and actions
    
    @IBOutlet private var imageView: UIImageView!

    @IBAction private func showMediaPicker() {
        
        let assemblyFactory = Paparazzo.AssemblyFactory(theme: PaparazzoUITheme.appSpecificTheme())
        let assembly = assemblyFactory.mediaPickerAssembly()
        
        let mediaPickerController = assembly.module(
            items: [],
            selectedItem: nil,
            maxItemsCount: 20,
            cropEnabled: true,
            cropCanvasSize: CGSize(width: 1280, height: 960),
            configuration: { [weak self] module in
                weak var module = module
                
                module?.setContinueButtonTitle("Done")
                
                module?.onFinish = { photos in
                    module?.dismissModule()
                    
                    // storing picked photos in instance var and updating UI
                    self?.photos = photos
                    self?.updateUI()
                }
                module?.onCancel = {
                    module?.dismissModule()
                }
            }
        )
        
        navigationController?.pushViewController(mediaPickerController, animated: true)
    }
    
    @IBAction private func showPhotoLibrary() {
        
        let assemblyFactory = Paparazzo.AssemblyFactory(theme: PaparazzoUITheme.appSpecificTheme())
        let assembly = assemblyFactory.photoLibraryAssembly()
        
        let galleryController = assembly.module(
            selectedItems: [],
            maxSelectedItemsCount: 5,
            configuration: { module in
                weak var module = module
                module?.onFinish = { result in
                    module?.dismissModule()
                }
            }
        )
        
        let navigationController = UINavigationController(rootViewController: galleryController)
        
        present(navigationController, animated: true, completion: nil)
    }
}
