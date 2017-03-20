import Foundation

extension Array {
    
    func elementAtIndex(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
    
    mutating func moveElement(from sourceIndex: Int, to destinationIndex: Int) {
        if let itemToMove = self.elementAtIndex(sourceIndex), 0 <= destinationIndex && destinationIndex < count {
            self.remove(at: sourceIndex)
            self.insert(itemToMove, at: destinationIndex)
        }
    }
}
