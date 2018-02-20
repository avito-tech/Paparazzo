import Paparazzo
import ImageIO
import Vision
import CoreML

@available(iOS 11.0, *)
final class ObjectsRecognitionStreamHandler: ScannerOutputHandler {
    
    let sampler = Sampler(delay: 0.1)
    
    var onRecognize: ((_ label: String) -> ())?
    
    var orientation: CGImagePropertyOrientation?
    
    var imageBuffer: CVImageBuffer? {
        didSet {
            sampler.sample { [weak self] in
                guard
                    let model = try? VNCoreMLModel(for: SqueezeNet().model),
                    let handleVisionRequestUpdate = self?.handleVisionRequestUpdate
                    else { return }
                let request = VNCoreMLRequest(model: model, completionHandler: handleVisionRequestUpdate)
                
                do {
                    if let imageBuffer = self?.imageBuffer {
                        try self?.visionSequenceHandler.perform([request], on: imageBuffer, orientation: self?.orientation ?? .left)
                    }
                } catch {
                    print("Throws: \(error)")
                }
            }
        }
    }
    
    private let visionSequenceHandler = VNSequenceRequestHandler()

    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let topResult = request.results?.first as? VNClassificationObservation else {
                return
            }
            
            self.onRecognize?(topResult.identifier)
            
        }
    }

}

