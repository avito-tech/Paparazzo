import UIKit

public struct PhotoLibraryV3Data {
    public let selectedItems: [PhotoLibraryV3Item]
    public let mediaPickerData: MediaPickerData
    
    public init(
        selectedItems: [PhotoLibraryV3Item] = [],
        mediaPickerData: MediaPickerData)
    {
        self.selectedItems = selectedItems
        self.mediaPickerData = mediaPickerData
    }
}
