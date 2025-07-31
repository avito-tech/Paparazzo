import UIKit

final class PhotoLibraryV3AlbumsTableView: UIView {
    
    // MARK: Properties
    
    private var cellDataList = [PhotoLibraryAlbumCellData]()
    private var selectedAlbumId: String?
    private let cellId = "AlbumCell"
    private var cellLabelFont: UIFont?
    private var cellBackgroundColor: UIColor?
    private var cellDefaultLabelColor: UIColor?
    private var cellSelectedLabelColor: UIColor?
    private var cellImageCornerRadius: CGFloat?
    
    // MARK: Spec
    
    private enum Spec {
        static let minInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    // MARK: UI elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.alwaysBounceVertical = false
        tableView.register(PhotoLibraryV3AlbumsTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.accessibilityIdentifier = AccessibilityId.albumsTableView.rawValue
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubview(tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let tableViewSize = tableView.sizeThatFits(size)
        return CGSize(
            width: tableViewSize.width,
            height: size.height
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            bottom: bounds.bottom
        )
        
        tableView.contentInset = UIEdgeInsets(
            top: Spec.minInsets.top,
            left: Spec.minInsets.left,
            bottom: max(Spec.minInsets.bottom, paparazzoSafeAreaInsets.bottom),
            right: Spec.minInsets.right
        )
    }
    
    // MARK: Public methods
    
    func setCellDataList(_ cellDataList: [PhotoLibraryAlbumCellData], completion: @escaping () -> ()) {
        self.cellDataList = cellDataList
        tableView.reloadData()
        
        // AI-7770: table view's size can be calculated incorrectly right after reloadData
        DispatchQueue.main.async(execute: completion)
    }
    
    func selectAlbum(withId id: String) {
        
        let indexPathsToReload = [selectedAlbumId, id].compactMap { albumId in
            cellDataList.firstIndex(where: { $0.identifier == albumId }).flatMap { IndexPath(row: $0, section: 0) }
        }
        
        selectedAlbumId = id
        
        tableView.reloadRows(at: indexPathsToReload, with: .fade)
    }
    
    func setTableViewBackgroundColor(_ color: UIColor) {
        tableView.backgroundColor = color
    }
    
    func setCellLabelFont(_ font: UIFont) {
        cellLabelFont = font
    }
    
    func setCellBackgroundColor(_ color: UIColor) {
        cellBackgroundColor = color
    }
    
    func setCellDefaultLabelColor(_ color: UIColor) {
        cellDefaultLabelColor = color
    }
    
    func setCellSelectedLabelColor(_ color: UIColor) {
        cellSelectedLabelColor = color
    }
    
    func setCellImageCornerRadius(_ radius: CGFloat) {
        cellImageCornerRadius = radius
    }
}

// MARK: - UITableViewDataSource

extension PhotoLibraryV3AlbumsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? PhotoLibraryV3AlbumsTableViewCell else {
            return UITableViewCell()
        }
        
        let cellData = cellDataList[indexPath.row]
        
        cell.setCellData(cellData)
        cell.isSelected = (cellData.identifier == selectedAlbumId)
        
        if let cellLabelFont {
            cell.setLabelFont(cellLabelFont)
        }
        
        if let cellBackgroundColor {
            cell.backgroundColor = cellBackgroundColor
        }
        
        if let cellDefaultLabelColor {
            cell.setDefaultLabelColor(cellDefaultLabelColor)
        }
        
        if let cellSelectedLabelColor {
            cell.setSelectedLabelColor(cellSelectedLabelColor)
        }
        
        if let cellImageCornerRadius {
            cell.setImageCornerRadius(cellImageCornerRadius)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PhotoLibraryV3AlbumsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = cellDataList[indexPath.row]
        cellData.onSelect()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
