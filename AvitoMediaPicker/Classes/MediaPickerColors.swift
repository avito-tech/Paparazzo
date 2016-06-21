public struct MediaPickerColors: PhotoLibraryColors {
    
    public var shutterButtonColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    public var mediaRibbonSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    
    public var photoLibraryItemSelectionColor = UIColor(red: 0, green: 170.0/255, blue: 1, alpha: 1)
    
    public init() {}
}

public protocol PhotoLibraryColors {
    var photoLibraryItemSelectionColor: UIColor { get }
}