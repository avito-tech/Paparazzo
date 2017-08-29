import AVFoundation

public protocol PhotoStorage {
    func savePhoto(
        sampleBuffer: CMSampleBuffer?,
        callbackQueue: DispatchQueue,
        completion: @escaping (PhotoFromCamera?) -> ()
    )
    func removePhoto(_ photo: PhotoFromCamera)
    func removeAll()
}


public final class PhotoStorageImpl: PhotoStorage {
    
    private static let folderName = "Paparazzo"
    
    private let createFolder = {
        PhotoStorageImpl.createPhotoDirectoryIfNotExist()
    }()
    
    // MARK: - Init
    public init() {}
    
    // MARK: - PhotoStorage
    public func savePhoto(
        sampleBuffer: CMSampleBuffer?,
        callbackQueue: DispatchQueue,
        completion: @escaping (PhotoFromCamera?) -> ())
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = sampleBuffer.flatMap({ AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation($0) })
            var photo: PhotoFromCamera? = nil
            if let imageData = imageData {
                let path = self.randomTemporaryPhotoFilePath()
                do {
                    try imageData.write(
                        to: URL(fileURLWithPath: path),
                        options: [.atomicWrite]
                    )
                    photo = PhotoFromCamera(path: path)
                } catch let error {
                    assert(false, "Couldn't save photo at path \(path) with error: \(error)")
                }
            }
            callbackQueue.async {
                completion(photo)
            }
        }
    }
    
    public func removePhoto(_ photo: PhotoFromCamera) {
        do {
            try FileManager.default.removeItem(atPath: photo.path)
        } catch let error {
            assert(false, "Couldn't remove photo at path \(photo.path) with error: \(error)")
        }
    }
    
    public func removeAll() {
        do {
            try FileManager.default.removeItem(atPath: PhotoStorageImpl.photoDirectoryPath())
            PhotoStorageImpl.createPhotoDirectoryIfNotExist()
        } catch let error {
            assert(false, "Couldn't remove photo folder with error: \(error)")
        }
    }
    
    // MARK: - Private
    
    private static func createPhotoDirectoryIfNotExist() {
        var isDirectory: ObjCBool = false
        let path = PhotoStorageImpl.photoDirectoryPath()
        let exist = FileManager.default.fileExists(
            atPath: path,
            isDirectory: &isDirectory
        )
        if !exist || !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(
                    atPath: PhotoStorageImpl.photoDirectoryPath(),
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch let error {
                assert(false, "Couldn't create folder for images with error: \(error)")
            }
        }
    }
    
    private static func photoDirectoryPath() -> String {
        let tempDirPath = NSTemporaryDirectory() as NSString
        return tempDirPath.appendingPathComponent(PhotoStorageImpl.folderName)
    }
    
    private func randomTemporaryPhotoFilePath() -> String {
        let tempName = "\(NSUUID().uuidString).jpg"
        let directoryPath = PhotoStorageImpl.photoDirectoryPath() as NSString
        return directoryPath.appendingPathComponent(tempName)
    }
    
}
