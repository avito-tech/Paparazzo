enum AspectRatio {
    
    case portrait_3x4
    case landscape_4x3
    
    static let defaultRatio = AspectRatio.landscape_4x3
    
    func widthToHeightRatio() -> Float {
        switch self {
        case .portrait_3x4:
            return Float(3.0 / 4.0)
        case .landscape_4x3:
            return Float(4.0 / 3.0)
        }
    }
    
    func heightToWidthRatio() -> Float {
        return 1 / widthToHeightRatio()
    }
    
    var description: String {
        switch self {
        case .portrait_3x4:
            return "3:4"
        case .landscape_4x3:
            return "4:3"
        }
    }
}
