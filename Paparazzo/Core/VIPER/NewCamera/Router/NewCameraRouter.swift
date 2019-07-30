protocol NewCameraRouter: class {
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
}
