import Paparazzo

extension PaparazzoUITheme {
    
    static func appSpecificTheme() -> PaparazzoUITheme {
        var theme = PaparazzoUITheme()
        theme.cancelRotationTitleFont = UIFont(name: "LatotoSemibold", size: 14)!
        theme.infoMessageFont = UIFont(name: "Latoto", size: 14)!
        return theme
    }
}
