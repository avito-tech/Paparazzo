import Foundation

protocol PhotoLibraryViewInput: class, ViewLifecycleObservable {
    
    func setItems(items: [PhotoLibraryItem])
}
