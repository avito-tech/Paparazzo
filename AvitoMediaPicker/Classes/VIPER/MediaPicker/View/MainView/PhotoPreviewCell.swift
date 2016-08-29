import UIKit

final class PhotoPreviewCell: PhotoCollectionViewCell {
    
    private let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .ScaleAspectFit
        imageView.addSubview(blurView)
        
        blurView.alpha = 0
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.color = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
        
        addSubview(progressIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressIndicator.center = bounds.center
        blurView.frame = imageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setProgressVisible(false)
    }
    
    override func adjustImageRequestOptions(inout options: ImageRequestOptions) {
        super.adjustImageRequestOptions(&options)
        
        options.onDownloadStart = { [weak self, superOptions = options] requestId in
            superOptions.onDownloadStart?(requestId)
            self?.imageRequestId = requestId
            self?.setProgressVisible(true)
        }
        
        options.onDownloadFinish = { [weak self, superOptions = options] requestId in
            superOptions.onDownloadFinish?(requestId)
            if requestId == self?.imageRequestId {
                self?.setProgressVisible(false)
            }
        }
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        imageSource = item.image
    }
    
    // MARK: - Private
    
    private var imageRequestId: ImageRequestId?
    
    private func setProgressVisible(visible: Bool) {
        
        if visible {
            progressIndicator.startAnimating()
        } else {
            progressIndicator.stopAnimating()
        }
        
        UIView.animateWithDuration(0.25) {
            self.blurView.alpha = visible ? 1 : 0
        }
    }
}
