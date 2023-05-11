import AVFAudio

protocol VolumeService: AnyObject {
    func subscribe()
    func unsubscribe()
    
    var volumeButtonTapped: (() -> ())? { get set }
}

final class VolumeServiceImpl: NSObject, VolumeService {
    private let audioSession: AVAudioSession
    var volumeButtonTapped: (() -> ())?
    
    func subscribe() {
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func unsubscribe() {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }
    
    init(audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.audioSession = audioSession
        super.init()
        
        try? audioSession.setActive(true)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        volumeButtonTapped?()
    }
}
