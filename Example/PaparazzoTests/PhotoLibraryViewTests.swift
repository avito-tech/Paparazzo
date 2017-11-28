@testable import Paparazzo
import XCTest

final class PhotoLibraryViewTests: XCTestCase {
    
    /// Fixes crash AI-7784
    func test_photoLibraryView_doesNotCrash_ifUserQuicklySwitchesToAlbumWithLessPhotos() {
        
        // Data
        let cellDataList1 = [
            PhotoLibraryItemCellData(image: ImageSourceStub(loadingTime: 0.25)),
            PhotoLibraryItemCellData(image: ImageSourceStub(loadingTime: 0.25)),
            PhotoLibraryItemCellData(image: ImageSourceStub(loadingTime: 0.25))
        ]
        
        let cellDataList2 = [
            PhotoLibraryItemCellData(image: ImageSourceStub(loadingTime: 0.25))
        ]
        
        // 1. Initialize view
        let view = PhotoLibraryView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        view.layoutIfNeeded()
        
        // 2. Simulate initial opening of album containing 3 photos
        view.setItems(cellDataList1, scrollToBottom: true, completion: nil)
        
        // 3. Simulate fast switching to an album with less than 3 photos
        // (switching must be performed before images are loaded)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            view.setItems(cellDataList2, scrollToBottom: true, completion: nil)
        }
        
        // 5. Wait enough time. It would crash in 0.25 seconds after step 2 before.
        // If it doesn't crash in 0.5 seconds, than everything is OK.
        let crashExpectation = expectation(description: "It must neved be fulfilled")
        crashExpectation.isInverted = true

        wait(for: [crashExpectation], timeout: 0.5)
    }
}
