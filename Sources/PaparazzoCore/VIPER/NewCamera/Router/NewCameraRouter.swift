protocol NewCameraRouter: AnyObject {
    func focusOnCurrentModule()
    
    func showMediaPicker(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
}
