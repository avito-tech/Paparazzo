import Photos

extension PHAuthorizationStatus {
    
    var isAuthorizedOrLimited: Bool {
        #if compiler(>=5.3)
        // Xcode 12+
        if #available(iOS 14, *) {
            return self == .authorized || self == .limited
        } else {
            return self == .authorized
        }
        #else
        return self == .authorized
        #endif
    }
}
