import AVFoundation

public protocol PhotoStorage {
    func savePhoto(
        sampleBuffer: CMSampleBuffer?,
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
        completion: @escaping (PhotoFromCamera?) -> ())
    {
        let path = randomTemporaryPhotoFilePath()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = sampleBuffer.flatMap({ AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation($0) }) {
                do {
                    try data.write(
                        to: URL(fileURLWithPath: path),
                        options: [.atomicWrite]
                    )
                    completion(PhotoFromCamera(path: path))
                } catch {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    public func removePhoto(_ photo: PhotoFromCamera) {
        do {
            try FileManager.default.removeItem(atPath: photo.path)
        } catch {
            assert(false, "Couldn't remove photo at path \(photo.path)")
        }
    }
    
    public func removeAll() {
        do {
            try FileManager.default.removeItem(atPath: PhotoStorageImpl.photoDirectoryPath())
            PhotoStorageImpl.createPhotoDirectoryIfNotExist()
        } catch {
            assert(false, "Couldn't remove photo folder")
        }
    }
    
    // MARK: - Private
    
    private static func createPhotoDirectoryIfNotExist() {
        var isDirectory : ObjCBool = false
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
            } catch {
                assert(false, "Couldn't create folder for images")
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
