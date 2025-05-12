import UIKit

public struct MediaPickerData {
    public let items: [MediaPickerItem]
    public let autocorrectionFilters: [Filter]
    public let selectedItem: MediaPickerItem?
    public let maxItemsCount: Int?
    public let cropEnabled: Bool
    public let autocorrectEnabled: Bool
    public let removeEnabled: Bool
    public let autoEnhanceEnabled: Bool
    public let hapticFeedbackEnabled: Bool
    public let cropCanvasSize: CGSize
    public let initialActiveCameraType: CameraType
    public let cameraEnabled: Bool
    public let photoLibraryEnabled: Bool
    public let hintText: String?
    
    public init(
        items: [MediaPickerItem] = [],
        autocorrectionFilters: [Filter] = [],
        selectedItem: MediaPickerItem? = nil,
        maxItemsCount: Int? = nil,
        cropEnabled: Bool = true,
        autocorrectEnabled: Bool = false,
        removeEnabled: Bool = true,
        autoEnhanceEnabled: Bool = false,
        hapticFeedbackEnabled: Bool = false,
        cropCanvasSize: CGSize = CGSize(width: 1280, height: 960),
        initialActiveCameraType: CameraType = .back,
        cameraEnabled: Bool = true,
        photoLibraryEnabled: Bool = true,
        hintText: String? = nil
    )
    {
        self.items = items
        self.autocorrectionFilters = autocorrectionFilters
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropEnabled = cropEnabled
        self.autocorrectEnabled = autocorrectEnabled
        self.removeEnabled = removeEnabled
        self.autoEnhanceEnabled = autoEnhanceEnabled
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.cropCanvasSize = cropCanvasSize
        self.initialActiveCameraType = initialActiveCameraType
        self.cameraEnabled = cameraEnabled
        self.photoLibraryEnabled = photoLibraryEnabled
        self.hintText = hintText
    }
}
