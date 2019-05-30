import AVFoundation
import MobileCoreServices
import ImageIO

public protocol ImageStorage {
    func save(
        sampleBuffer: CMSampleBuffer?,
        callbackQueue: DispatchQueue,
        completion: @escaping (String?) -> ()
    )
    func save(_ image: CGImage) -> String?
    func remove(_ path: String)
    func removeAll()
}

public final class ImageStorageImpl: ImageStorage {

    private static let folderName = "Paparazzo"
    
    private let createFolder = {
        ImageStorageImpl.createImageDirectoryIfNotExist()
    }()
    
    // MARK: - Init
    public init() {}
    
    // MARK: - ImageStorage
    public func save(
        sampleBuffer: CMSampleBuffer?,
        callbackQueue: DispatchQueue,
        completion: @escaping (String?) -> ())
    {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = sampleBuffer.flatMap({ AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation($0) })
            var destination: String? = nil
            if let imageData = imageData {
                let path = self.randomTemporaryImageFilePath()
                do {
                    try imageData.write(
                        to: URL(fileURLWithPath: path),
                        options: [.atomicWrite]
                    )
                    destination = path
                } catch let error {
                    assert(false, "Couldn't save photo at path \(path) with error: \(error)")
                }
            }
            callbackQueue.async {
                completion(destination)
            }
        }
    }
    
    public func save(_ image: CGImage) -> String? {
        let path = self.randomTemporaryImageFilePath()
        let url = URL(fileURLWithPath: path)
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeJPEG, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        if CGImageDestinationFinalize(destination) {
            return path
        } else { return nil }
    }
    
    public func remove(_ path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error {
            assert(false, "Couldn't remove photo at path \(path) with error: \(error)")
        }
    }
    
    public func removeAll() {
        let imageDirectoryPath = ImageStorageImpl.imageDirectoryPath()
        guard FileManager.default.fileExists(atPath: imageDirectoryPath) else {
            return
        }

        do {
            try FileManager.default.removeItem(atPath: imageDirectoryPath)
            ImageStorageImpl.createImageDirectoryIfNotExist()
        } catch let error {
            assert(false, "Couldn't remove photo folder with error: \(error)")
        }
    }
    
    // MARK: - Private
    
    private static func createImageDirectoryIfNotExist() {
        var isDirectory: ObjCBool = false
        let path = ImageStorageImpl.imageDirectoryPath()
        let exist = FileManager.default.fileExists(
            atPath: path,
            isDirectory: &isDirectory
        )
        if !exist || !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(
                    atPath: ImageStorageImpl.imageDirectoryPath(),
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch let error {
                assert(false, "Couldn't create folder for images with error: \(error)")
            }
        }
    }
    
    private static func imageDirectoryPath() -> String {
        let tempDirPath = NSTemporaryDirectory() as NSString
        return tempDirPath.appendingPathComponent(ImageStorageImpl.folderName)
    }
    
    private func randomTemporaryImageFilePath() -> String {
        let tempName = "\(NSUUID().uuidString).jpg"
        let directoryPath = ImageStorageImpl.imageDirectoryPath() as NSString
        return directoryPath.appendingPathComponent(tempName)
    }
    
}
