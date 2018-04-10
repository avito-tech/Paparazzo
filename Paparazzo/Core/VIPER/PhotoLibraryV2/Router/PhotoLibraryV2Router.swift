protocol PhotoLibraryV2Router: class {
    func dismissCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ()
    )
}
