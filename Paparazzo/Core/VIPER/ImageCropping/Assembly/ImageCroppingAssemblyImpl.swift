import ImageSource
import UIKit

public final class ImageCroppingAssemblyImpl: ImageCroppingAssembly {
    
    private let theme: ImageCroppingUITheme
    
    init(theme: ImageCroppingUITheme) {
        self.theme = theme
    }
    
    public func module(
        image: ImageSource,
        canvasSize: CGSize,
        configure: (ImageCroppingModule) -> ()
    ) -> UIViewController {

        let interactor = ImageCroppingInteractorImpl(image: image, canvasSize: canvasSize)

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
