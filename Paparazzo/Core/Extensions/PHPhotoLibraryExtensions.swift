import Photos

extension PHPhotoLibrary {
    
    static func readWriteAuthorizationStatus() -> PHAuthorizationStatus {
        #if compiler(>=5.3)
        // Xcode 12+
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
        #else
        return PHPhotoLibrary.authorizationStatus()
        #endif
    }
    
    static func requestReadWriteAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> ()) {
        #if compiler(>=5.3)
        // Xcode 12+
        if #available(iOS 14, *) {
            return PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
        } else {
            return PHPhotoLibrary.requestAuthorization(handler)
        }
        #else
        return PHPhotoLibrary.requestAuthorization(handler)
        #endif
    }
}
