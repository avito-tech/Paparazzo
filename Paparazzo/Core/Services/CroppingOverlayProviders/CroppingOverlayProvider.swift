import UIKit

public protocol CroppingOverlayProvider: class {
    func calculateRectToCrop(in bounds: CGRect) -> CGRect
    func croppingPath(in rect: CGRect) -> CGPath
}
