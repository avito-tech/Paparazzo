import Foundation
import ImageSource
import UIKit

protocol ImageCroppingInteractor: AnyObject {
    
    func canvasSize(completion: @escaping (CGSize) -> ())
    
    func imageWithParameters(completion: @escaping (ImageCroppingData) -> ())
    func croppedImage(previewImage: CGImage, completion: @escaping (CroppedImageSource) -> ())
    func croppedImageAspectRatio(completion: @escaping (Float) -> ())
    
    func setCroppingParameters(_: ImageCroppingParameters)
}
