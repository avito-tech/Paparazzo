import Foundation

class ExampleViewItem {
    
    let title: String
    let onTap: (() -> ())?
    
    init(title: String, onTap: (() -> ())?) {
        self.title = title
        self.onTap = onTap
    }
}

protocol ExampleViewInput: class {
    var onViewDidLoad: (() -> ())? { get set }
    func setItems(_: [ExampleViewItem])
}
