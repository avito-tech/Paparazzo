internal enum AccessibilityId: String {
    // CameraControls
    case photoView
    case shutterButton
    case cameraToggleButton
    case flashButton

    // Cells
    case cameraThumbnailCell
    case mainCameraCell
    case mediaItemThumbnailCell
    case photoPreviewCell

    // ImageCropping
    case rotationButton
    case gridButton
    case rotationCancelButton
    case confirmButton
    case discardButton
    case aspectRatioButton
    case titleLabel
    
    // MediaPicker
    case continueButton
    case closeButton

    // PhotoControls
    case removeButton
    case cropButton
}

extension UIView {
    func setAccessibilityId(_ id: AccessibilityId) {
        accessibilityIdentifier = id.rawValue
        isAccessibilityElement = true
    }
    
    func setAccessibilityId(_ id: String) {
        accessibilityIdentifier = id
        isAccessibilityElement = true
    }
}
