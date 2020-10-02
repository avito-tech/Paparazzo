import Photos

extension PHPhotoLibrary {
    
    static func readWriteAuthorizationStatus() -> PHAuthorizationStatus {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            return PHPhotoLibrary.authorizationStatus()
        }
    }
    
    static func requestReadWriteAuthorization(_ handler: @escaping (PHAuthorizationStatus) -> ()) {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: handler)
        } else {
            return PHPhotoLibrary.requestAuthorization(handler)
        }
    }
}
