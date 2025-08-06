protocol CameraV3Router: AnyObject {
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        isPaparazzoImageUpdaingFixEnabled: Bool,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
}
