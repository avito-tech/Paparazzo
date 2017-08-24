final class InfoMessageDisplayer {
    
    init() {}
    
    private let infoMessageFactory = InfoMessageViewFactoryImpl()
    
    @discardableResult
    func display(viewData: InfoMessageViewData, in container: UIView) -> InfoMessageViewInput {
        let (messageView, animator) = infoMessageFactory.create(from: viewData)
        animator.appear(messageView: messageView, in: container)
        return animator
    }
}

protocol InfoMessageDisplayable: class {
    @discardableResult
    func showInfoMessage(_ viewData: InfoMessageViewData) -> InfoMessageViewInput
}

extension InfoMessageDisplayable where Self: UIViewController {
    func showInfoMessage(_ viewData: InfoMessageViewData) -> InfoMessageViewInput {
        return InfoMessageDisplayer().display(viewData: viewData, in: self.view)
    }
}

