import UIKit

protocol ViewLifecycleObservable {
    var onViewDidLoad: (() -> ())? { get set }
    var onViewWillAppear: (() -> ())? { get set }
    var onViewDidAppear: (() -> ())? { get set }
    var onViewWillDisappear: (() -> ())? { get set }
    var onViewDidDisappear: (() -> ())? { get set }
}

protocol DisposeBag {
    func addDisposable(anyObject: AnyObject)
}

protocol DisposeBagHolder {
    var disposeBag: DisposeBag { get }
}

// Default `DisposeBag` implementation
extension DisposeBag where Self: DisposeBagHolder {
    func addDisposable(anyObject: AnyObject) {
        disposeBag.addDisposable(anyObject)
    }
}

// Non thread safe `DisposeBag` implementation
final class DisposeBagImpl: DisposeBag {
    private var disposables: [AnyObject] = []
    
    func addDisposable(anyObject: AnyObject) {
        disposables.append(anyObject)
    }
}

class BaseViewControllerSwift: UIViewController, ViewLifecycleObservable, DisposeBag, DisposeBagHolder {
    
    // MARK: - ViewLifecycleObservable
    
    var onViewDidLoad: (() -> ())?
    var onViewWillAppear: (() -> ())?
    var onViewDidAppear: (() -> ())?
    var onViewWillDisappear: (() -> ())?
    var onViewDidDisappear: (() -> ())?
    
    // MARK: - DisposeBagHolder
    
    let disposeBag: DisposeBag = DisposeBagImpl()
    
    // MARK: - Lifecycle
    
    @nonobjc init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message="use init")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewDidLoad?()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        onViewWillAppear?()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        onViewDidAppear?()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        onViewWillDisappear?()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        onViewDidDisappear?()
    }
}