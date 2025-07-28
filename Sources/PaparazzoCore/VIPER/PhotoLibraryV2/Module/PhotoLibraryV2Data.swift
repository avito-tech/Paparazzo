import UIKit

@available(*, deprecated, message: "Use PhotoLibraryV3Data instead")
public struct PhotoLibraryV2Data {
    public let selectedItems: [PhotoLibraryItem]
    public let mediaPickerData: MediaPickerData
    
    public init(
        selectedItems: [PhotoLibraryItem] = [],
        mediaPickerData: MediaPickerData)
    {
        self.selectedItems = selectedItems
        self.mediaPickerData = mediaPickerData
    }
}
