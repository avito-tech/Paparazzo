import UIKit

class PaparazzoViewController: UIViewController, DisposeBag, DisposeBagHolder {
    // MARK: - DisposeBagHolder
    public let disposeBag: DisposeBag = DisposeBagImpl()

    @nonobjc public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
