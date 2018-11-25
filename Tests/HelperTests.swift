import XCTest

@testable import ImageExtract

class HelperTests: XCTestCase {

    func testSubscriptData() {
        let smallData: Data = "00".data(using: .ascii)!
        let largeData: Data = "0000000000000000000000".data(using: .ascii)!
        let rangeData: Data = largeData[0..<2]
        let offsetData: UInt16 = largeData[0, 2]

        XCTAssertEqual(rangeData.count, smallData.count)
        XCTAssertEqual(offsetData, 12336)
    }

}
