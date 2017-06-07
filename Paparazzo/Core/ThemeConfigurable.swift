public protocol ThemeConfigurable {
    associatedtype ThemeType
    
    func setTheme(_ theme: ThemeType)
}
