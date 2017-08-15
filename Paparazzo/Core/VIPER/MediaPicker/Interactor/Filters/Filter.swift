import Foundation

public protocol Filter {
    func apply(_ sourceImage: MediaPickerItem, completion: @escaping ((_ resultImage: MediaPickerItem) -> Void))
}
