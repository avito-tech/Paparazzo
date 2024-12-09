import UIKit

public protocol CroppingOverlayProvider: AnyObject {
    func calculateRectToCrop(in bounds: CGRect) -> CGRect
    func croppingPath(in rect: CGRect) -> CGPath
}
