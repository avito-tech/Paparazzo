import AvitoMediaPicker

extension MediaPickerUITheme {
    
    static func appSpecificTheme() -> MediaPickerUITheme {
        var theme = MediaPickerUITheme()
        theme.cancelRotationTitleFont = UIFont(name: "LatotoSemibold", size: 14)!
        return theme
    }
}