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
            guard let viewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController else {
                return
            }
            
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: viewController)
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
