protocol CameraV3Router: AnyObject {
    func focusOnCurrentModule()
    
    func showMediaPicker(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
}
