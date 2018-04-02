import Foundation

protocol ExampleViewInput: class {
    
    func setMediaPickerButtonTitle(_ title: String)
    func setMaskCropperButtonTitle(_ title: String)
    func setPhotoLibraryButtonTitle(_ title: String)
    func setPhotoLibraryV2ButtonTitle(_ title: String)
    func setScannerButtonTitle(_ title: String)
    
    var onShowMediaPickerButtonTap: (() -> ())? { get set }
    var onShowMaskCropperButtonTap: (() -> ())? { get set }
    var onShowPhotoLibraryButtonTap: (() -> ())? { get set }
    var onShowPhotoLibraryV2ButtonTap: (() -> ())? { get set }
    var onShowScannerButtonTap: (() -> ())? { get set }
}
