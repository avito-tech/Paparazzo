protocol PhotoLibraryV2Router: AnyObject {
    func dismissCurrentModule()
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        configure: (MediaPickerModule) -> ()
    )
    
    func showNewCamera(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        shouldAllowFinishingWithNoPhotos: Bool,
        configure: (NewCameraModule) -> ()
    )
    
    func showCameraV3(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        configure: (CameraV3Module) -> ()
    )
    
    @available(iOS 14, *)
    func showLimitedAccessAlert()
}
