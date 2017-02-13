public enum ImageSizeOption: Equatable {
    
    case fitSize(CGSize)
    case fillSize(CGSize)
    case fullResolution
    
    public static func ==(sizeOption1: ImageSizeOption, sizeOption2: ImageSizeOption) -> Bool {
        switch (sizeOption1, sizeOption1) {
        case (.fitSize(let size1), .fitSize(let size2)):
            return size1 == size2
        case (.fillSize(let size1), .fillSize(let size2)):
            return size1 == size2
        case (.fullResolution, .fullResolution):
            return true
        default:
            return false
        }
    }
}
