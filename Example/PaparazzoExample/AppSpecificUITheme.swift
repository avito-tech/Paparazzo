import Paparazzo

extension PaparazzoUITheme {
    
    static func appSpecificTheme() -> PaparazzoUITheme {
        var theme = PaparazzoUITheme()
        theme.cancelRotationTitleFont = UIFont(name: "LatotoSemibold", size: 14)!
        theme.cameraTitleFont = UIFont(name: "LatotoSemibold", size: 17)!
        return theme
    }
}
