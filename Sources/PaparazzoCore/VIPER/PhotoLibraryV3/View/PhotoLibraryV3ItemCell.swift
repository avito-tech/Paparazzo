import ImageSource
import UIKit

final class PhotoLibraryV3ItemCell: UIImageSourceCollectionViewCell, Customizable {
    
    // MARK: Properties
    
    private var imageRequestId: ImageRequestId?
    
    var selectionIndexFont: UIFont? {
        get { return selectionIndexBadge.font }
        set { selectionIndexBadge.font = newValue }
    }
    
    var selectedBorderColor: CGColor? {
        get { selectionIndexBadgeContainer.layer.borderColor }
        set { selectionIndexBadgeContainer.layer.borderColor = newValue }
    }
    
    override var backgroundColor: UIColor? {
        get { return backgroundView?.backgroundColor }
        set { backgroundView?.backgroundColor = newValue }
    }
    
    // MARK: UI elements
    
    private let cloudIconView = UIImageView()
    
    private lazy var selectionIndexBadgeContainer: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(ciColor: .black).cgColor
        return view
    }()
    
    private lazy var selectionIndexBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 10)
        label.size = CGSize(width: 19, height: 19)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    // MARK: Handler
    
    private var getSelectionIndex: (() -> Int?)?
    
    var onImageSetFromSource: (() -> ())?
    
    // MARK: UICollectionViewCell
    
    func adjustAppearanceForSelected(_ isSelected: Bool, animated: Bool) {
        
        func adjustAppearance() {
            if isSelected {
                self.selectionIndexBadgeContainer.alpha = 1
            } else {
                self.selectionIndexBadgeContainer.alpha = 0
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
        
        imageView.isAccessibilityElement = true
        imageViewInsets = .zero
        
        setUpRoundedCorners(for: self)
        setUpRoundedCorners(for: backgroundView)
        setUpRoundedCorners(for: imageView)
        setUpRoundedCorners(for: selectionIndexBadgeContainer)
        
        selectionIndexBadgeContainer.alpha = 0
        selectionIndexBadgeContainer.backgroundColor = .clear
        selectionIndexBadgeContainer.addSubview(selectionIndexBadge)
        
        contentView.insertSubview(cloudIconView, at: 0)
        contentView.addSubview(selectionIndexBadgeContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = imageView.frame
        
        cloudIconView.sizeToFit()
        cloudIconView.right = contentView.bounds.right
        cloudIconView.bottom = contentView.bounds.bottom
        
        selectionIndexBadgeContainer.center = imageView.center
        selectionIndexBadgeContainer.bounds = imageView.bounds
        
        selectionIndexBadge.layout(
            right: contentView.bounds.right - 8,
            top: contentView.bounds.top + 8
        )
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
    
    func customizeWithItem(_ item: PhotoLibraryV3ItemCellData) {
        imageSource = item.image
        getSelectionIndex = item.getSelectionIndex
        isSelected = item.selected
    }
    
    // MARK: - Private
    
    private func setUpRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.nativeScale
    }
}
