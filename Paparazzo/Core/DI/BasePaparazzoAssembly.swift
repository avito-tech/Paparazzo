public class BasePaparazzoAssembly {
    // MARK: - Dependencies
    let theme: PaparazzoUITheme
    let serviceFactory: ServiceFactory
    
    init(theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.theme = theme
        self.serviceFactory = serviceFactory
    }
    
}
