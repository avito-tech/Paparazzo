import Foundation

public protocol Filter {
    func apply(_ sourceItem: MediaPickerItem, completion: @escaping ((_ resultItem: MediaPickerItem) -> Void))
}
