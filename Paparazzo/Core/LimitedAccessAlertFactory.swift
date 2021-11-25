import PhotosUI

public protocol LimitedAccessAlertFactory: AnyObject {
    @available(iOS 14, *)
    func limitedAccessAlert() -> UIAlertController
}

public final class LimitedAccessAlertFactoryImpl: LimitedAccessAlertFactory {
    public init() {}
    
    @available(iOS 14, *)
    public func limitedAccessAlert() -> UIAlertController {
        let limitedAccessAlert = UIAlertController(
            title: "Приложение «Авито» запрашивает доступ к Фото",
            message: "Приложению нужен доступ к галерее, чтобы прикреплять фотографии к объявлению",
            preferredStyle: .alert
        )
        
        let selectPhotosAction = UIAlertAction(
            title: "Выбрать еще фото...",
            style: .default
        ) { _ in
            guard let topViewController = UIApplication.shared.topViewController else { return }
            
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: topViewController)
        }
        
        limitedAccessAlert.addAction(selectPhotosAction)
        
        let cancelAction = UIAlertAction(title: "Не менять выбор", style: .default, handler: nil)
        limitedAccessAlert.addAction(cancelAction)
        
        let allowFullAccessAction = UIAlertAction(
            title: "Перейти в настройки",
            style: .default
        ) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    
        limitedAccessAlert.addAction(allowFullAccessAction)
        
        return limitedAccessAlert
    }
}

private extension UIApplication {
    func findTopViewController(in viewController: UIViewController?) -> UIViewController? {
        func searchIntoNavigation(_ navVC: UINavigationController) -> UIViewController? {
            return findTopViewController(in: navVC.topViewController)
        }
        func searchIntoTab(_ tabVC: UITabBarController) -> UIViewController? {
            guard let selectedViewController = tabVC.selectedViewController else {
                return nil
            }
            if let selectedNav = selectedViewController as? UINavigationController {
                return searchIntoNavigation(selectedNav)
            }
            return selectedViewController
        }
        if var topController = viewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if let navController = topController as? UINavigationController {
                return searchIntoNavigation(navController)
            }
            if let tabController = topController as? UITabBarController {
                return searchIntoTab(tabController)
            }
            return topController
        }
        return viewController
    }
    
    var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        return findTopViewController(in: keyWindow?.rootViewController)
    }
}
