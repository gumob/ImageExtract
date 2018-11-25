import XCTest

@testable import ImageExtract

class ImageDecoderTests: XCTestCase {

    func testZeroByteData() {
        XCTAssertEqual(JPGDecoder.getSize(Data()), CGSize.zero)
        XCTAssertEqual(PNGDecoder.getSize(Data()), CGSize.zero)
        XCTAssertEqual(GIFDecoder.getSize(Data()), CGSize.zero)
        XCTAssertEqual(BMPDecoder.getSize(Data()), CGSize.zero)
//        XCTAssertEqual(TIFFDecoder.decodeSize(Data()), CGSize.zero) /* TODO: Support TIFF (low priority) */
        XCTAssertEqual(WEBPDecoder.getSize(Data()), CGSize.zero)
    }

}
