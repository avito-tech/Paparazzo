import UIKit

public struct PhotoLibraryV2Data {
    public let selectedItems: [PhotoLibraryItem]
    public let maxSelectedItemsCount: Int?
    public let mediaPickerData: MediaPickerData
    
    public init(
        selectedItems: [PhotoLibraryItem] = [],
        maxSelectedItemsCount: Int? = nil,
        mediaPickerData: MediaPickerData)
    {
        self.selectedItems = selectedItems
        self.maxSelectedItemsCount = maxSelectedItemsCount
        self.mediaPickerData = mediaPickerData
    }
}
