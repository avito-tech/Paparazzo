import CoreLocation
import ImageIO
import ImageSource

protocol ImageMetadataWritingService {
    func writeGpsData(from: CLLocation, to: LocalImageSource, completion: ((_ success: Bool) -> ())?)
}

final class ImageMetadataWritingServiceImpl: ImageMetadataWritingService {
    
    // MARK: - ImageMetadataWritingService
    func writeGpsData(
        from location: CLLocation,
        to imageSource: LocalImageSource,
        completion: ((_ success: Bool) -> ())?)
    {
        DispatchQueue.global(qos: .background).async {
            let url = NSURL(fileURLWithPath: imageSource.path)
            let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            
            guard let source = CGImageSourceCreateWithURL(url, sourceOptions),
                let sourceType = CGImageSourceGetType(source),
                let destination = CGImageDestinationCreateWithURL(url, sourceType, 1, nil)
            else {
                completion?(false)
                return
            }
            
            let gpsMetadata = self.gpsMetadataDictionary(for: location) as [NSObject: AnyObject]
            
            let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
                .flatMap { metadata in
                    var metadata = metadata as [NSObject: AnyObject]
                    metadata.merge(gpsMetadata) { current, _ in current }
                    return metadata
                }
                ?? gpsMetadata
            
            CGImageDestinationAddImageFromSource(destination, source, 0, metadata as CFDictionary)
            let success = CGImageDestinationFinalize(destination)
            
            completion?(success)
        }
    }
    
    // MARK: - Private
    private func gpsMetadataDictionary(for location: CLLocation?) -> [CFString: Any] {
        guard let coordinate = location?.coordinate else { return [:] }
        
        return [
            kCGImagePropertyGPSDictionary: [
                kCGImagePropertyGPSLatitude: coordinate.latitude,
                kCGImagePropertyGPSLatitudeRef: coordinate.latitude < 0.0 ? "S" : "N",
                kCGImagePropertyGPSLongitude: coordinate.longitude,
                kCGImagePropertyGPSLongitudeRef: coordinate.longitude < 0.0 ? "W" : "E"
            ]
        ]
    }
}
