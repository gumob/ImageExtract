import XCTest

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

@testable import ImageExtract

class ImageFormatTests: XCTestCase {

    /* Zero byte data */
    func testZeroBytes() {
        let jpgData: Data = Data(repeating: 0, count: 10)
        let jpgFormat: ImageJPGFormat = ImageJPGFormat(data: jpgData)
        XCTAssertEqual(jpgFormat, ImageJPGFormat.unsupported)

        let webpData: Data = Data(repeating: 0, count: 16)
        let webpFormat: ImageWebPFormat = ImageWebPFormat(data: webpData)
        XCTAssertEqual(webpFormat, ImageWebPFormat.unsupported)
    }

    /* Invalid byte data */
    func testInvalidBytesJPG1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-jfif-end.jpg"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesJPG2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx.jpg"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8-no-space.webp"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8x-end.webp"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-xxxx.webp"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP4() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-xxxx-vp8x.webp"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP5() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-zero-byte.webp"
        let size: CGSize = ImageExtract.extract(request.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

}
