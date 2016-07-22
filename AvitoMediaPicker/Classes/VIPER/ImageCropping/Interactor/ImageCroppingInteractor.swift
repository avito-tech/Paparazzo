import Foundation

protocol ImageCroppingInteractor: class {
    func setCroppingParameters(_: ImageCroppingParameters)
    func performCrop(completion: ImageSource -> ())
}