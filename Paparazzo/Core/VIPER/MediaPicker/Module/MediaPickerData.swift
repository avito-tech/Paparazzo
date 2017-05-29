import UIKit

public struct MediaPickerData {
    public let items: [MediaPickerItem]
    public let selectedItem: MediaPickerItem?
    public let maxItemsCount: Int?
    public let cropEnabled: Bool
    public let cropCanvasSize: CGSize
    public let initialActiveCameraType: CameraType
    
    public init(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropEnabled: Bool,
        cropCanvasSize: CGSize,
        initialActiveCameraType: CameraType = .back)
    {
        self.items = items
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropEnabled = cropEnabled
        self.cropCanvasSize = cropCanvasSize
        self.initialActiveCameraType = initialActiveCameraType
    }
}
