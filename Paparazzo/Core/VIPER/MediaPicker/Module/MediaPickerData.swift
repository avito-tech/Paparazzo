import UIKit

public struct MediaPickerData {
    public let items: [MediaPickerItem]
    public let autocorrectionFilters: [Filter]
    public let selectedItem: MediaPickerItem?
    public let maxItemsCount: Int?
    public let cropEnabled: Bool
    public let autocorrectEnabled: Bool
    public let cropCanvasSize: CGSize
    public let initialActiveCameraType: CameraType
    
    public init(
        items: [MediaPickerItem],
        autocorrectionFilters: [Filter] = [],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropEnabled: Bool,
        autocorrectEnabled: Bool = false,
        cropCanvasSize: CGSize,
        initialActiveCameraType: CameraType = .back)
    {
        self.items = items
        self.autocorrectionFilters = autocorrectionFilters
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropEnabled = cropEnabled
        self.autocorrectEnabled = autocorrectEnabled
        self.cropCanvasSize = cropCanvasSize
        self.initialActiveCameraType = initialActiveCameraType
    }
}
