public protocol ImageCroppingUITheme {
    var rotationIcon: UIImage? { get }
    var gridIcon: UIImage? { get }
    var gridSelectedIcon: UIImage? { get }
    var cropperDiscardIcon: UIImage? { get }
    var cropperConfirmIcon: UIImage? { get }
    
    var cancelRotationBackgroundColor: UIColor { get }
    var cancelRotationTitleColor: UIColor { get }
    var cancelRotationTitleFont: UIFont { get }
    var cancelRotationButtonIcon: UIImage? { get }
}
