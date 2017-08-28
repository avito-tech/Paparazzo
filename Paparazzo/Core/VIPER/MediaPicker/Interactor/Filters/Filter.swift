import ImageSource

public protocol Filter {
    func apply(_ sourceImage: ImageSource, completion: @escaping ((_ sourceImage: ImageSource) -> Void))
    
    var fallbackMessage: String? { get }
}
