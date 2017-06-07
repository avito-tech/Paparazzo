public protocol CroppingOverlayProvidersFactory: class {
    func circleCroppingOverlayProvider() -> CroppingOverlayProvider
    func rectangleCroppingOverlayProvider(cornerRadius: CGFloat, margin: CGFloat) -> CroppingOverlayProvider
    func heartShapeCroppingOverlayProvider() -> CroppingOverlayProvider
}

public class CroppingOverlayProvidersFactoryImpl: CroppingOverlayProvidersFactory {
    
    public init() {}
    
    public func circleCroppingOverlayProvider() -> CroppingOverlayProvider {
        return CircleCroppingOverlayProvider()
    }
    
    public func rectangleCroppingOverlayProvider(cornerRadius: CGFloat, margin: CGFloat) -> CroppingOverlayProvider {
        return RectangleCroppingOverlayProvider(cornerRadius: cornerRadius, margin: margin)
    }
    
    public func heartShapeCroppingOverlayProvider() -> CroppingOverlayProvider {
        return HeartShapeCroppingOverlayProvider()
    }
    
}
