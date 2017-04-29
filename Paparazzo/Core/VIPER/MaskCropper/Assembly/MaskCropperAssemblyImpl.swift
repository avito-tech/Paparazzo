import ImageSource
import UIKit

public final class MaskCropperAssemblyImpl: BasePaparazzoAssembly, MaskCropperAssembly {
    
    public func module(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        configure: (MaskCropperModule) -> ()
        ) -> UIViewController {
        
        let imageCroppingService = serviceFactory.imageCroppingService(
            image: data.photo.image,
            canvasSize: data.cropCanvasSize
        )
        
        let interactor = MaskCropperInteractorImpl(
            imageCroppingService: imageCroppingService
        )
        
        let viewController = MaskCropperViewController(
            croppingOverlayProvider: croppingOverlayProvider
        )
        
        let router = CircleImageCropperUIKitRouter(
            viewController: viewController
        )
        
        let presenter = MaskCropperPresenter(
            interactor: interactor,
            router: router
        )

        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
    
}
