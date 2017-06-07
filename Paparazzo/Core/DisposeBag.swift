protocol DisposeBag {
    func addDisposable(_: AnyObject)
}

protocol DisposeBagHolder {
    var disposeBag: DisposeBag { get }
}

// Default `DisposeBag` implementation
extension DisposeBag where Self: DisposeBagHolder {
    func addDisposable(_ anyObject: AnyObject) {
        disposeBag.addDisposable(anyObject)
    }
}

// Non thread safe `DisposeBag` implementation
final class DisposeBagImpl: DisposeBag {
    // MARK: - Private properties
    private var disposables: [AnyObject] = []
    
    // MARK: - Init
    init() {}
    
    // MARK: - DisposeBag
    func addDisposable(_ anyObject: AnyObject) {
        disposables.append(anyObject)
    }
}
