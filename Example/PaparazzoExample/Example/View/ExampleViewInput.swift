import Foundation

protocol ExampleViewInput: class {
    var onShowMediaPickerButtonTap: (() -> ())? { get set }
    var onShowPhotoLibraryButtonTap: (() -> ())? { get set }
}
