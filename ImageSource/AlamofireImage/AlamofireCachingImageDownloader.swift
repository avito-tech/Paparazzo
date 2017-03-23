import AlamofireImage
import Alamofire

extension AlamofireImage.ImageDownloader: CachingImageDownloader {
    
    public func downloadImageAtUrl(
        _ url: URL,
        progressHandler: ((_ receivedSize: Int64, _ expectedSize: Int64) -> ())?,
        completion: @escaping (_ image: CGImage?, _ error: Error?) -> ())
        -> CancellableImageDownload
    {
        let request = URLRequest(url: url)
        let progress: (Progress) -> () = { progress in
            progressHandler?(progress.completedUnitCount, progress.totalUnitCount)
        }
        let downloadCompletion: (DataResponse<Image>) -> () = { response in
            let image = response.result.value
            completion(image?.cgImage, response.result.error)
        }
        let requestReceipt = download(
            request,
            progress: progress,
            completion: downloadCompletion)
        return AlamofireCancellableImageDownloadAdapter(receipt: requestReceipt)
    }
    
    public func cachedImageForUrl(_ url: URL) -> CGImage? {
        let request = URLRequest(url: url)
        if let image = imageCache?.image(for: request, withIdentifier: nil) {
            return image.cgImage
        } else {
            return nil
        }
    }
}

final class AlamofireCancellableImageDownloadAdapter: CancellableImageDownload {
    
    let receipt: RequestReceipt?
    
    init(receipt: RequestReceipt?) {
        self.receipt = receipt
    }
    
    func cancel() {
        receipt?.request.cancel()
    }
}
