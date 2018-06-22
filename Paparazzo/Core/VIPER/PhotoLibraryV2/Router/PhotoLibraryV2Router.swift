protocol PhotoLibraryV2Router: class {
    func dismissCurrentModule()
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        metalEnabled: Bool,
        configure: (MediaPickerModule) -> ()
    )
}
