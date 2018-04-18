protocol PhotoLibraryV2Router: class {
    func dismissCurrentModule()
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ()
    )
}
