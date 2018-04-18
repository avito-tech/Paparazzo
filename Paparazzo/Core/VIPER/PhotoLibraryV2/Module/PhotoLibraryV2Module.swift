import Foundation

public protocol PhotoLibraryV2Module: class {
    
    func focusOnModule()
    func dismissModule()
    
    var onFinish: ((PhotoLibraryV2ModuleResult) -> ())? { get set }
    func finish()
    
    func setContinueButtonTitle(_: String)
    func setContinueButtonEnabled(_: Bool)
    func setContinueButtonVisible(_: Bool)
    func setContinueButtonStyle(_: MediaPickerContinueButtonStyle)
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    func setCameraTitle(_: String)
    func setCameraSubtitle(_: String)
    func setCameraHint(data: CameraHintData)
    
    func setCropMode(_: MediaPickerCropMode)
    func setThumbnailsAlwaysVisible(_: Bool)
    
    func removeItem(_: MediaPickerItem)
    
    // startIndex - index of element in previous array of MediaPickerItem, new elements were added after that index
    var onItemsAdd: (([MediaPickerItem], _ startIndex: Int) -> ())? { get set }
    var onItemUpdate: ((MediaPickerItem, _ index: Int?) -> ())? { get set }
    var onItemAutocorrect: ((MediaPickerItem, _ isAutocorrected: Bool, _ index: Int?) -> ())? { get set }
    var onItemMove: ((_ sourceIndex: Int, _ destinationIndex: Int) -> ())? { get set }
    var onItemRemove: ((MediaPickerItem, _ index: Int?) -> ())? { get set }
    var onCropFinish: (() -> ())? { get set }
    var onCropCancel: (() -> ())? { get set }
    var onContinueButtonTap: (() -> ())? { get set }
}

public enum PhotoLibraryV2ModuleResult {
    case selectedItems([MediaPickerItem])
    case cancelled
}
