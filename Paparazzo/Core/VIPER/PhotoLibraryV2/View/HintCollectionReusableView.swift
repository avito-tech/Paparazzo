import Foundation
import UIKit

final class HintCollectionReusableView: UICollectionReusableView {
    // UI сделаю в следующих задачах
    static let maxHintViewHeight: CGFloat = 70
    static let minHintViewHeight: CGFloat = 42
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
