import XCTest
import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

@testable import ImageExtract

final class ImageExtractSyncTests: XCTestCase {

    var dataSet: DataSet!

    override func setUp() {
        super.setUp()
        guard let url: URL = Bundle.current.url(forResource: "TestImage", withExtension: "json"),
              let data: Data = try? Data(contentsOf: url),
              let dataSet: DataSet = try? JSONDecoder().decode(DataSet.self, from: data) else { return }
        self.dataSet = dataSet
    }

    /* Invalid URL */
    func testInvalidURL1() {
        let request: String = "https://"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidURL2() {
        let request: String = "localhost"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidURL3() {
        let request: String = ""
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    /* Large header file */
    func testLargeHeaderJPG1() {
        let url: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-large-header-0.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(url.withRandomQuery())
        XCTAssertEqual(result.size, .zero)
    }

    func testLargeHeaderJPG2() {
        let url: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-large-header-1.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(url.withRandomQuery())
        XCTAssertEqual(result.size, .zero)
    }

    /* Invalid byte data */
    func testInvalidBytesJPG1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-jfif-end.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesJPG2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesJPG3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx-full.jpg"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesWEBP1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8-no-space.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesWEBP2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8x-end.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesWEBP3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-xxxx.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesWEBP4() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-xxxx-vp8x.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    func testInvalidBytesWEBP5() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-zero-byte.webp"
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(request)
        XCTAssertEqual(result.size, .zero)
    }

    /* Utility extension */
    func testUtilityExtension() {
        XCTAssertNotNil(self.dataSet.png)
        let image: DataSet.Image = self.dataSet.png.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery(), preferredWidth: 600)
        XCTAssertEqual(result.size, result.isFinished ? CGSize(width: 600, height: 399) : .zero)
    }

    /* Single download */
    func testSinglePNG() {
        XCTAssertNotNil(self.dataSet.png)
        let image: DataSet.Image = self.dataSet.png.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(result.size, result.isFinished ? image.size : .zero)
    }

    func testSingleJPG() {
        XCTAssertNotNil(self.dataSet.jpg)
        let image: DataSet.Image = self.dataSet.jpg.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(result.size, result.isFinished ? image.size : .zero)
    }

    func testSingleGIF() {
        XCTAssertNotNil(self.dataSet.gif)
        let image: DataSet.Image = self.dataSet.gif.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(result.size, result.isFinished ? image.size : .zero)
    }

    func testSingleBMP() {
        XCTAssertNotNil(self.dataSet.bmp)
        let image: DataSet.Image = self.dataSet.bmp.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(result.size, result.isFinished ? image.size : .zero)
    }

    /* TODO: Support TIFF (low priority) */
    func testSingleTIF() {
        XCTAssertNotNil(self.dataSet.tif)
        let image: DataSet.Image = self.dataSet.tif.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery())
        /* Unsupported. Returns zero */
//        XCTAssertEqual(result.size, result.isFinished ? image.size : .zero)
        XCTAssertEqual(result.size, .zero)
    }

    func testSingleWebP() {
        XCTAssertNotNil(self.dataSet.webp)
        let image: DataSet.Image = self.dataSet.webp.first!
        let result: (size: CGSize, isFinished: Bool) = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(result.size, result.isFinished ? image.size : .zero)
    }
}
