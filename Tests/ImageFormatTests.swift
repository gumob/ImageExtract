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
        /* TODO: Test with data on a remote server */
        let jpgData1: Data = Data(repeating: 0, count: 0)
        let jpgFormat1: ImageFormat = ImageFormat(data: jpgData1)
        XCTAssertEqual(jpgFormat1, ImageFormat.unknown)

        let jpgData: Data = Data(repeating: 0, count: 10)
        let jpgFormat: ImageJPGFormat = ImageJPGFormat(data: jpgData)
        XCTAssertEqual(jpgFormat, ImageJPGFormat.unsupported)

        let webpData1: Data = Data(repeating: 0, count: 16)
        let webpFormat1: ImageWebPFormat = ImageWebPFormat(data: webpData1)
        XCTAssertEqual(webpFormat1, ImageWebPFormat.unsupported)

        let webpData2: Data = Data(repeating: 0, count: 15)
        let webpFormat2: ImageWebPFormat = ImageWebPFormat(data: webpData2)
        XCTAssertEqual(webpFormat2, ImageWebPFormat.unsupported)
    }

    /* Invalid byte data */
    func testInvalidBytesJPG1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-jfif-end.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesJPG2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesJPG3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx-full.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesWEBP1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8-no-space.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesWEBP2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8x-end.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesWEBP3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-xxxx.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesWEBP4() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-xxxx-vp8x.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

    func testInvalidBytesWEBP5() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-zero-byte.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request.withRandomQuery())
        XCTAssertEqual(result.size, CGSize.zero)
    }

}
