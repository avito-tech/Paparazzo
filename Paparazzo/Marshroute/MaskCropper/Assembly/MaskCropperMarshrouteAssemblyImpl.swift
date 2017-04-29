import Marshroute
import UIKit

public final class MaskCropperMarshrouteAssemblyImpl: BasePaparazzoAssembly, MaskCropperMarshrouteAssembly {
    
    public func module(
        data: MaskCropperData,
        croppingOverlayProvider: CroppingOverlayProvider,
        routerSeed: RouterSeed,
        configure: (MaskCropperModule) -> ()
        ) -> UIViewController {
        
        let imageCroppingService = serviceFactory.imageCroppingService(
            image: data.photo.image,
            canvasSize: data.cropCanvasSize
        )
        
        let interactor = MaskCropperInteractorImpl(
            imageCroppingService: imageCroppingService
        )
        
        let router = MaskCropperMarshrouteRouter(
            routerSeed: routerSeed
        )
        
        let presenter = MaskCropperPresenter(
            interactor: interactor,
            router: router
        )
        
        let viewController = MaskCropperViewController(
            croppingOverlayProvider: croppingOverlayProvider
        )
        viewController.addDisposable(presenter)
        viewController.setTheme(theme)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }

}
