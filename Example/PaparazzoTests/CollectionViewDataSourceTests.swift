@testable import Paparazzo
import XCTest

final class CollectionViewDataSourceTests: XCTestCase {
    
    private var dataSource: CollectionViewDataSource<CellModel>!
    
    override func setUp() {
        super.setUp()
        dataSource = CollectionViewDataSource<CellModel>(cellReuseIdentifier: "cell")
    }
    
    func test_insertToTheBeginning() {
        dataSource.setItems(["foo"])
        
        dataSource.insertItems([
            (item: "bar", indexPath: IndexPath(item: 0)),
            (item: "tub", indexPath: IndexPath(item: 1))
        ])
        
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 0)), "bar")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 1)), "tub")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 2)), "foo")
    }
    
    func test_insertToTheEnd() {
        dataSource.setItems(["foo"])
        
        dataSource.insertItems([
            (item: "bar", indexPath: IndexPath(item: 1)),
            (item: "tub", indexPath: IndexPath(item: 2))
        ])
        
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 0)), "foo")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 1)), "bar")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 2)), "tub")
    }
    
    func test_insertToTheMiddle() {
        dataSource.setItems(["foo", "bar", "tub"])
        
        dataSource.insertItems([
            (item: "buzz", indexPath: IndexPath(item: 1)),
            (item: "words", indexPath: IndexPath(item: 3))
        ])
        
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 0)), "foo")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 1)), "buzz")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 2)), "bar")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 3)), "words")
        XCTAssertEqual(dataSource.item(at: IndexPath(item: 4)), "tub")
    }
}

private final class CellModel: Customizable {
    func customizeWithItem(_ item: String) {}
}

extension IndexPath {
    init(item: Int) {
        self.init(item: item, section: 0)
    }
}
