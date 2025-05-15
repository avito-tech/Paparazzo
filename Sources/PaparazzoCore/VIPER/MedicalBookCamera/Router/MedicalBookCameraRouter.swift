protocol MedicalBookCameraRouter: AnyObject {
    func focusOnCurrentModule()
    
    func showMediaPicker(
        isPhotoFetchLimitEnabled: Bool,
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
}
