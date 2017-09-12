protocol InfoMessageViewFactory: class {
    
    func create(
        from viewData: InfoMessageViewData
        ) -> (
        view: InfoMessageView,
        animator: InfoMessageAnimator
    )
}

final class InfoMessageViewFactoryImpl: InfoMessageViewFactory {
    
    func create(
        from viewData: InfoMessageViewData
        ) -> (
        view: InfoMessageView,
        animator: InfoMessageAnimator)
    {
        let animation = DefaultInfoMessageAnimatorBehavior()
        let data = InfoMessageAnimatorData(animation: animation, timeout: viewData.timeout, onDismiss: nil)
        let animator = InfoMessageAnimator(data)
        
        let messageView = InfoMessageView()
        messageView.setViewData(viewData)
        
        return (view: messageView, animator: animator)
    }
}
