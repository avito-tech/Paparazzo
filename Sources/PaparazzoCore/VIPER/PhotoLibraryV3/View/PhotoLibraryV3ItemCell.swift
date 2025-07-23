import ImageSource
import UIKit

final class PhotoLibraryV3ItemCell: PhotoCollectionViewCell, Customizable {
    
    private let cloudIconView = UIImageView()
    private var getSelectionIndex: (() -> Int?)?
    
    private let selectionIndexBadgeContainer = UIView()
    
    private let selectionIndexBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 0, green: 0.67, blue: 1, alpha: 1)
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.size = CGSize(width: 24, height: 24)
        label.textAlignment = .center
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        return label
    }()
    
    var selectionIndexFont: UIFont? {
        get { return selectionIndexBadge.font }
        set { selectionIndexBadge.font = newValue }
    }
    
    // MARK: - UICollectionViewCell
    
    override var backgroundColor: UIColor? {
        get { return backgroundView?.backgroundColor }
        set { backgroundView?.backgroundColor = newValue }
    }
    
    func adjustAppearanceForSelected(_ isSelected: Bool, animated: Bool) {
        
        func adjustAppearance() {
            if isSelected {
//                if isRedesign {
                    self.selectedBorderColor = .black
                    self.selectedBorderThickness = 2
                    self.selectionIndexBadgeContainer.alpha = 1
//                } else {
//                    self.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//                    self.selectionIndexBadgeContainer.transform = self.imageView.transform
//                    self.selectionIndexBadgeContainer.alpha = 1
//                }
            } else {
//                if isRedesign {
                    self.selectedBorderColor = .clear
                    self.selectedBorderThickness = 0
                    self.selectionIndexBadgeContainer.alpha = 0
//                } else {
//                    self.imageView.transform = .identity
//                    self.selectionIndexBadgeContainer.transform = self.imageView.transform
//                    self.selectionIndexBadgeContainer.alpha = 0
//                }
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: adjustAppearance)
        } else {
            adjustAppearance()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        getSelectionIndex = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundView = UIView()
        let onePixel = 1.0 / UIScreen.main.nativeScale
        
        selectedBorderThickness = 2
        
        imageView.isAccessibilityElement = true
        imageViewInsets = .zero /*UIEdgeInsets(top: onePixel, left: onePixel, bottom: onePixel, right: onePixel)*/
        
        setUpRoundedCorners(for: self)
        setUpRoundedCorners(for: backgroundView)
        setUpRoundedCorners(for: imageView)
        setUpRoundedCorners(for: selectionIndexBadgeContainer)
        
        selectionIndexBadgeContainer.alpha = 0
        selectionIndexBadgeContainer.backgroundColor = .clear /* UIColor.black.withAlphaComponent(0.4)*/
        selectionIndexBadgeContainer.addSubview(selectionIndexBadge)
        
        contentView.insertSubview(cloudIconView, at: 0)
        contentView.addSubview(selectionIndexBadgeContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let onePixel = CGFloat(1) / UIScreen.main.nativeScale
//        let backgroundInsets = UIEdgeInsets(top: onePixel, left: onePixel, bottom: onePixel, right: onePixel)
//        
        backgroundView?.frame = imageView.frame/*.inset(by: backgroundInsets)*/
        
        cloudIconView.sizeToFit()
        cloudIconView.right = contentView.bounds.right
        cloudIconView.bottom = contentView.bounds.bottom
        
        selectionIndexBadgeContainer.center = imageView.center
        selectionIndexBadgeContainer.bounds = imageView.bounds
        
        selectionIndexBadge.center = CGPoint(x: 18, y: 18)
    }
    
    override func didRequestImage(requestId imageRequestId: ImageRequestId) {
        self.imageRequestId = imageRequestId
    }
    
    override func imageRequestResultReceived(_ result: ImageRequestResult<UIImage>) {
        if result.requestId == self.imageRequestId {
            onImageSetFromSource?()
        }
    }
    
    // MARK: - PhotoLibraryV3ItemCell
    
    func setBadgeBackgroundColor(_ color: UIColor?) {
        selectionIndexBadge.backgroundColor = color
    }
    
    func setBadgeTextColor(_ color: UIColor?) {
        selectionIndexBadge.textColor = color
    }
    
    func setCloudIcon(_ icon: UIImage?) {
        cloudIconView.image = icon
        setNeedsLayout()
    }
    
    func setAccessibilityId(index: Int) {
        accessibilityIdentifier = AccessibilityId.mediaItemThumbnailCell.rawValue + "-\(index)"
    }
    
    func setSelectionIndex(_ selectionIndex: Int?) {
        selectionIndexBadge.text = selectionIndex.flatMap { String($0) }
    }
    
    // MARK: - Customizable
    
    var onImageSetFromSource: (() -> ())?
    
    func customizeWithItem(_ item: PhotoLibraryV3ItemCellData) {
        imageSource = item.image
        getSelectionIndex = item.getSelectionIndex
        isSelected = item.selected
    }
    
    // MARK: - Private
    
    private var imageRequestId: ImageRequestId?
    
    private func setUpRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.nativeScale
    }
}
