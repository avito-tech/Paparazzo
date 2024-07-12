import UIKit

public struct PhotoLibraryData {
    public let selectedItems: [PhotoLibraryItem]
    public let maxSelectedItemsCount: Int?
    
    public init(
        selectedItems: [PhotoLibraryItem] = [],
        maxSelectedItemsCount: Int? = nil)
    {
        self.selectedItems = selectedItems
        self.maxSelectedItemsCount = maxSelectedItemsCount
    }
}
