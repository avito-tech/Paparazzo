protocol PhotoLibraryV2Router: class {
    func dismissCurrentModule()
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isMetalEnabled: Bool,
        configure: (MediaPickerModule) -> ()
    )
    
    func showNewCamera(
        selectedImagesStorage: SelectedImageStorage,
        configure: (NewCameraModule) -> ()
    )
}
