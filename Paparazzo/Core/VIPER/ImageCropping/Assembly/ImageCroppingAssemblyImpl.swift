import ImageSource
import UIKit

public final class ImageCroppingAssemblyImpl: BasePaparazzoAssembly , ImageCroppingAssembly {
    
    public func module(
        image: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ()
    ) -> UIViewController {
        
        let imageCroppingService = serviceFactory.imageCroppingService(
            image: image,
            canvasSize: canvasSize
        )

        let interactor = ImageCroppingInteractorImpl(
            imageCroppingService: imageCroppingService
        )

        let presenter = ImageCroppingPresenter(
            interactor: interactor
        )

        let viewController = ImageCroppingViewController()
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)

        presenter.view = viewController
        
        configure(presenter)

        return viewController
    }
}
