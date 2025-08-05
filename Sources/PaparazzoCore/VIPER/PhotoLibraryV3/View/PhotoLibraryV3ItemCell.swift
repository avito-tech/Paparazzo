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
    
    private lazy var imageOverlay = CALayer()
    
    private lazy var cloudIconView = UIImageView()
    
    private lazy var selectionIndexBadgeContainer: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(ciColor: .black).cgColor
        return view
    }()
    
    private lazy var selectionIndexBadge: UILabel = {
        let label = UILabel()
        label.size = CGSize(width: 19, height: 19)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        return label
    }()
    
    // MARK: Handler
    
    private var getSelectionIndex: (() -> Int?)?
    
    var onImageSetFromSource: (() -> ())?
    
    // MARK: Init
    
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
        selectionIndexBadgeContainer.addSubview(selectionIndexBadge)
        
        imageView.layer.addSublayer(imageOverlay)
        contentView.insertSubview(cloudIconView, at: 0)
        contentView.addSubview(selectionIndexBadgeContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = imageView.frame
        
        cloudIconView.sizeToFit()
        cloudIconView.right = contentView.bounds.right
        cloudIconView.bottom = contentView.bounds.bottom
        
        imageOverlay.frame = imageView.bounds
        
        selectionIndexBadgeContainer.center = imageView.center
        selectionIndexBadgeContainer.bounds = imageView.bounds
        
        selectionIndexBadge.layout(
            right: contentView.bounds.right - 8,
            top: contentView.bounds.top + 8
        )
    }
    
    // MARK: Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        getSelectionIndex = nil
    }
    
    override func didRequestImage(requestId imageRequestId: ImageRequestId) {
        self.imageRequestId = imageRequestId
    }
    
    override func imageRequestResultReceived(_ result: ImageRequestResult<UIImage>) {
        if result.requestId == self.imageRequestId {
            onImageSetFromSource?()
        }
    }
    
    // MARK: Public methods
    
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
    
    func setImageOverlayColor(_ color: UIColor?) {
        imageOverlay.backgroundColor = color?.cgColor
    }
    
    func setBadgeCornerRadius(_ radius: CGFloat?) {
        guard let radius else { return }
        selectionIndexBadge.layer.cornerRadius = radius
    }
    
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
}

// MARK: - Private methods

private extension PhotoLibraryV3ItemCell {
    func setUpRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.nativeScale
    }
}
