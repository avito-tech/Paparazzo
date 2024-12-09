import UIKit

public enum InfoMessageViewDismissType {
    case interactive
    case timeout
    case force
}

struct InfoMessageAnimatorData {
    
    let animation: InfoMessageAnimatorBehavior
    let timeout: TimeInterval
    let onDismiss: ((InfoMessageViewDismissType) -> ())?
    
    init(
        animation: InfoMessageAnimatorBehavior,
        timeout: TimeInterval = 0.0,
        onDismiss: ((InfoMessageViewDismissType) -> ())?)
    {
        self.animation = animation
        self.timeout = timeout
        self.onDismiss = onDismiss
    }
}

private enum AnimatorState {
    case initial
    case appearing
    case appeared
    case dismissingByTimer
    case dismissingByDismissFunction
    case dismissed
}

final class InfoMessageAnimator: InfoMessageViewInput {
    
    private weak var container: UIView?
    private weak var messageView: InfoMessageView?
    
    private var dismissingByTimerDebouncer: Debouncer
    
    // Constant settings
    private let behavior: InfoMessageAnimatorBehavior
    private let onDismiss: ((InfoMessageViewDismissType) -> ())?
    
    // Updatable settings
    private var timeout: TimeInterval
    
    // Other state
    private var state = AnimatorState.initial
    
    init(_ data: InfoMessageAnimatorData)
    {
        behavior = data.animation
        onDismiss = data.onDismiss
        timeout = data.timeout
        dismissingByTimerDebouncer = Debouncer(delay: timeout)
    }
    
    // MARK: - Interface
    func appear(messageView: InfoMessageView, in container: UIView) {
        self.container = container
        self.messageView = messageView
        
        messageView.size = messageView.sizeThatFits(container.size)
        behavior.configure(messageView: messageView, in: container)
        container.addSubview(messageView)
        container.bringSubviewToFront(messageView)
        
        changeState(to: .appearing)
    }
    
    func dismiss() {
        changeState(to: .dismissingByDismissFunction)
    }
    
    func update(timeout: TimeInterval) {
        self.timeout = timeout
        dismissingByTimerDebouncer.cancel()
        dismissingByTimerDebouncer = Debouncer(delay: timeout)
        
        switch state {
        case .initial, .appearing:
            // dismissing is not scheduled
            break
        case .appeared:
            scheduleDismissing()
            
        case .dismissingByTimer, .dismissingByDismissFunction, .dismissed:
            // scheduling is not needed
            break
        }
    }
    
    // MARK: - States
    private func changeState(to newState: AnimatorState) {
        guard allowedTransitions().contains(newState) else { return }
        state = newState
        
        switch newState {
        case .initial:
            break
        case .appearing:
            animateAppearing()
        case .appeared:
            scheduleDismissing()
        case .dismissingByTimer:
            animateDismissing(dismissType: .timeout)
        case .dismissingByDismissFunction:
            animateDismissing(dismissType: .force)
        case .dismissed:
            messageView?.removeFromSuperview()
        }
    }
    
    private func allowedTransitions() -> [AnimatorState] {
        switch state {
        case .initial:
            return [.appearing, .dismissingByDismissFunction]
        case .appearing:
            return [.appeared, .dismissingByDismissFunction]
        case .appeared:
            return [.dismissingByTimer, .dismissingByDismissFunction]
        case .dismissingByTimer, .dismissingByDismissFunction:
            return [.dismissed]
        case .dismissed:
            return []
        }
    }
    
    private func scheduleDismissing() {
        if timeout.isZero {
            dismissingByTimerDebouncer.cancel()
        } else {
            dismissingByTimerDebouncer.debounce { [weak self] in
                self?.changeState(to: .dismissingByTimer)
            }
        }
    }
    
    // MARK: - Animations
    private func animateAppearing() {
        guard
            let messageView = self.messageView,
            let container = self.container
            else { return }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.1,
            options: .curveEaseIn,
            animations: {
                self.behavior.present(messageView: messageView, in: container)
        },
            completion: {_ in
                self.changeState(to: .appeared)
        }
        )
    }
    
    private func animateDismissing(dismissType: InfoMessageViewDismissType) {
        guard
            let messageView = self.messageView,
            let container = self.container
            else { return }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.behavior.dismiss(messageView: messageView, in: container)
        },
            completion: {_ in
                self.changeState(to: .dismissed)
                self.onDismiss?(dismissType)
        }
        )
    }
}

