import UIKit

public struct MediaPickerSettings {
    public let items: [MediaPickerItem]
    public let selectedItem: MediaPickerItem?
    public let maxItemsCount: Int?
    public let cropEnabled: Bool
    public let cropCanvasSize: CGSize
    public let initalActiveCamera: CameraType
    
    public init(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropEnabled: Bool,
        cropCanvasSize: CGSize,
        initialActiveCamera: CameraType = .back)
    {
        self.items = items
        self.selectedItem = selectedItem
        self.maxItemsCount = maxItemsCount
        self.cropEnabled = cropEnabled
        self.cropCanvasSize = cropCanvasSize
        self.initalActiveCamera = initialActiveCamera
    }
}
