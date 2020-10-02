import UIKit

final class PhotoLibraryAlbumsTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Subviews
    private let topSeparator = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Data
    private var cellDataList = [PhotoLibraryAlbumCellData]()
    private var selectedAlbumId: String?
    
    private let cellId = "AlbumCell"
    private var cellLabelFont: UIFont?
    private var cellBackgroundColor: UIColor?
    private var cellDefaultLabelColor: UIColor?
    private var cellSelectedLabelColor: UIColor?
    
    private let separatorHeight: CGFloat = 1
    private let minInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        topSeparator.backgroundColor = UIColor.RGB(red: 215, green: 215, blue: 215)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        tableView.alwaysBounceVertical = false
        tableView.register(PhotoLibraryAlbumsTableViewCell.self, forCellReuseIdentifier: cellId)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        addSubview(tableView)
        addSubview(topSeparator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PhotoLibraryAlbumsTableView
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
    
    func setTopSeparatorColor(_ color: UIColor) {
        topSeparator.backgroundColor = color
    }
    
    func setCellDefaultLabelColor(_ color: UIColor) {
        cellDefaultLabelColor = color
    }
    
    func setCellSelectedLabelColor(_ color: UIColor) {
        cellSelectedLabelColor = color
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? PhotoLibraryAlbumsTableViewCell else {
            return UITableViewCell()
        }
        
        let cellData = cellDataList[indexPath.row]
        
        cell.setCellData(cellData)
        cell.isSelected = (cellData.identifier == selectedAlbumId)
        
        if let cellLabelFont = cellLabelFont {
            cell.setLabelFont(cellLabelFont)
        }
        
        if let cellBackgroundColor = cellBackgroundColor {
            cell.backgroundColor = cellBackgroundColor
        }
        
        if let cellDefaultLabelColor = cellDefaultLabelColor {
            cell.setDefaultLabelColor(cellDefaultLabelColor)
        }
        
        if let cellSelectedLabelColor = cellSelectedLabelColor {
            cell.setSelectedLabelColor(cellSelectedLabelColor)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = cellDataList[indexPath.row]
        cellData.onSelect()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UIView
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let tableViewSize = tableView.sizeThatFits(size)
        let tableVerticalInsets = minInsets.top + minInsets.bottom
        return CGSize(
            width: tableViewSize.width,
            height: min(size.height, tableViewSize.height + separatorHeight + tableVerticalInsets)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topSeparator.layout(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: separatorHeight
        )
        
        tableView.layout(
            left: bounds.left,
            right: bounds.right,
            top: topSeparator.bottom,
            bottom: bounds.bottom
        )
        
        tableView.contentInset = UIEdgeInsets(
            top: minInsets.top,
            left: minInsets.left,
            bottom: max(minInsets.bottom, paparazzoSafeAreaInsets.bottom),
            right: minInsets.right
        )
    }
}
