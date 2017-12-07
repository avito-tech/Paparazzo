import Paparazzo

extension PaparazzoUITheme {
    
    static func appSpecificTheme() -> PaparazzoUITheme {
        var theme = PaparazzoUITheme()
        theme.cancelRotationTitleFont = UIFont(name: "LatotoSemibold", size: 14)!
        theme.infoMessageFont = UIFont(name: "Latoto", size: 14)!
        theme.photoLibraryTitleFont = UIFont(name: "LatotoSemibold", size: 18)!
        theme.photoLibraryAlbumCellFont = UIFont(name: "Latoto", size: 17)!
        theme.photoLibraryPlaceholderFont = UIFont(name: "Latoto", size: 17)!
        return theme
    }
}
