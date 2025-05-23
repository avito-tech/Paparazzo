import UIKit

public enum MediaPickerCropMode {
    case normal
    case custom(CroppingOverlayProvider)
}

public enum MediaPickerContinueButtonStyle {
    case normal
    case spinner
}

public enum MediaPickerContinueButtonPlacement {
    case topRight
    case bottom
}

public struct CameraHintData {
    public let title: String
    public let delay: TimeInterval?
    
    public init(
        title: String,
        delay: TimeInterval? = nil)
    {
        self.title = title
        self.delay = delay
    }
}

public enum MediaPickerImageState {
    case select(MediaPickerItem)
    case update
}

public protocol PaparazzoPickerModule: AnyObject {
    
    func focusOnModule()
    func dismissModule()
    
    func finish()
    
    func setContinueButtonTitle(_: String)
    func setContinueButtonEnabled(_: Bool)
    func setContinueButtonVisible(_: Bool)
    func setContinueButtonStyle(_: MediaPickerContinueButtonStyle)
    func setContinueButtonPlacement(_: MediaPickerContinueButtonPlacement)
    
    func setAccessDeniedTitle(_: String)
    func setAccessDeniedMessage(_: String)
    func setAccessDeniedButtonTitle(_: String)
    
    func setCameraTitle(_: String)
    func setCameraSubtitle(_: String)
    func setCameraHint(data: CameraHintData)
    
    func setCropMode(_: MediaPickerCropMode)
    func setThumbnailsAlwaysVisible(_: Bool)
    
    func setAutoEnhanceImage(_ image: MediaPickerItem?, prevImage: MediaPickerItem, isEnhanced: Bool)
    func setImagePerceptionBadge(_ badge: ImagePerceptionBadgeViewData)
        
    func removeItem(_: MediaPickerItem)
    
    // startIndex - index of element in previous array of MediaPickerItem, new elements were added after that index
    var onItemsAdd: (([MediaPickerItem], _ startIndex: Int) -> ())? { get set }
    var onItemUpdate: ((MediaPickerItem, _ index: Int?) -> ())? { get set }
    var onItemAutocorrect: ((MediaPickerItem, _ isAutocorrected: Bool, _ index: Int?) -> ())? { get set }
    var onItemMove: ((_ sourceIndex: Int, _ destinationIndex: Int) -> ())? { get set }
    var onItemRemove: ((MediaPickerItem, _ index: Int?) -> ())? { get set }
    var onItemAutoEnhance: ((MediaPickerItem, _ isAllowedEnhance: Bool) -> ())? { get set }
    var onItemSelectSetAutoEnhanceStatusIfNeeded: ((MediaPickerItem) -> ())? { get set }
    var onCropFinish: (() -> ())? { get set }
    var onCropCancel: (() -> ())? { get set }
    var onContinueButtonTap: (() -> ())? { get set }
    var onCropButtonTap: (() -> ())? { get set }
    var onLastPhotoThumbnailTap: (() -> ())? { get set }
    var onRotationAngleChange: (() -> ())? { get set }
    var onRotateButtonTap: (() -> ())? { get set }
    var onGridButtonTap: ((Bool) -> ())? { get set }
    var onAspectRatioButtonTap: ((String) -> ())? { get set }
    var onItemStateDidChange: ((MediaPickerImageState) -> ())? { get set }
    
    var onViewDidLoad: (() -> ())? { get set }
    var onFinish: (([MediaPickerItem]) -> ())? { get set }
    var onCancel: (() -> ())? { get set }
}
