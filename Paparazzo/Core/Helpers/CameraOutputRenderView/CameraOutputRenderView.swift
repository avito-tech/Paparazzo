import Foundation
import AVFoundation
import GLKit
import ImageSource
import MetalKit

protocol CameraOutputRenderView: class {
    var frame: CGRect { get set }
    var orientation: ExifOrientation { get set }
    var onFrameDraw: (() -> ())? { get set }
}
