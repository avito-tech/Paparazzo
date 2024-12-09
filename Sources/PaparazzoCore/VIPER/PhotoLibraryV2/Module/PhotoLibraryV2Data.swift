import UIKit

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
