import UIKit

final class PhotoLibraryView: UIView, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Subviews
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: PhotoLibraryLayout())
    
    private let dataSource = CollectionViewDataSource<PhotoLibraryItemCell>(
        cellReuseIdentifier: PhotoLibraryItemCell.reuseIdentifier
    )
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        dataSource.onDataChanged = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        backgroundColor = .whiteColor()
        
        collectionView.backgroundColor = .whiteColor()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.registerClass(
            PhotoLibraryItemCell.self,
            forCellWithReuseIdentifier: dataSource.cellReuseIdentifier
        )
        
        addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
    
    // MARK: - PhotoLibraryView
    
    func setItems(items: [PhotoLibraryItem]) {
        dataSource.setItems(items)
    }
}