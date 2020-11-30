import UIKit

public struct PhotoLibraryData {
    public let selectedItems: [PhotoLibraryItem]
    public let maxSelectedItemsCount: Int?
    public let showVideos: Bool
    
    public init(
        selectedItems: [PhotoLibraryItem] = [],
        maxSelectedItemsCount: Int? = nil,
        showVideos: Bool = false)
    {
        self.selectedItems = selectedItems
        self.maxSelectedItemsCount = maxSelectedItemsCount
        self.showVideos = showVideos
    }
}
