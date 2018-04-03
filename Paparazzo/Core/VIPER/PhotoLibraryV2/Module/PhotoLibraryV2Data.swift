import UIKit

public struct PhotoLibraryV2Data {
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
