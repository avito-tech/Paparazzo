protocol PhotoLibraryV2Router: AnyObject {
    func dismissCurrentModule()
    func focusOnCurrentModule()
    
    func showMediaPicker(
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        isNewFlowPrototype: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (MediaPickerModule) -> ()
    )
    
    func showNewCamera(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        shouldAllowFinishingWithNoPhotos: Bool,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (NewCameraModule) -> ()
    )
    
    func showCameraV3(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (CameraV3Module) -> (),
        cameraV3MeasureInitialization: (() -> ())?,
        cameraV3InitializationMeasurementStop: (() -> ())?,
        cameraV3DrawingMeasurement: (() -> ())?
    )
    
    @available(iOS 14, *)
    func showLimitedAccessAlert()
}
