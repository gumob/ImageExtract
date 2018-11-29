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

    /* User Agent */
    func testGetterSetter() {
        let ua: String = "User Agent"
        let extractor: ImageExtract = ImageExtract()
        extractor.userAgent = ua
        XCTAssertEqual(extractor.userAgent, extractor.userAgent)

        extractor.maxConnectionsPerHost = 10
        XCTAssertEqual(extractor.maxConnectionsPerHost, ImageLoader.httpMaximumConnectionsPerHost)
    }

    /* Invalid URL */
    func testInvalidURL1() {
        let request: String = "https://"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidURL2() {
        let request: String = "localhost"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidURL3() {
        let request: String = ""
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    /* Large header file */
    func testLargeHeaderJPG1() {
        let url: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-large-header-0.jpg"
        let size: CGSize = ImageExtract().extract(url.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    func testLargeHeaderJPG2() {
        let url: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-large-header-1.jpg"
        let size: CGSize = ImageExtract().extract(url.withRandomQuery())
        XCTAssertEqual(size, CGSize.zero)
    }

    /* Invalid byte data */
    func testInvalidBytesJPG1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-jfif-end.jpg"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesJPG2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx.jpg"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesJPG3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx-full.jpg"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP1() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8-no-space.webp"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP2() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8x-end.webp"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP3() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-xxxx.webp"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP4() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-xxxx-vp8x.webp"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidBytesWEBP5() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-zero-byte.webp"
        let size: CGSize = ImageExtract().extract(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    /* Utility extension */
    func testUtilityExtension() {
        XCTAssertNotNil(self.dataSet.png)
        let image: DataSet.Image = self.dataSet.png.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery(), preferredWidth: 600)
        XCTAssertEqual(size, CGSize(width: 600, height: 399))
    }

    /* Single download */
    func testSinglePNG() {
        XCTAssertNotNil(self.dataSet.png)
        let image: DataSet.Image = self.dataSet.png.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(size, image.size)
    }

    func testSingleJPG() {
        XCTAssertNotNil(self.dataSet.jpg)
        let image: DataSet.Image = self.dataSet.jpg.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(size, image.size)
    }

    func testSingleGIF() {
        XCTAssertNotNil(self.dataSet.gif)
        let image: DataSet.Image = self.dataSet.gif.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(size, image.size)
    }

    func testSingleBMP() {
        XCTAssertNotNil(self.dataSet.bmp)
        let image: DataSet.Image = self.dataSet.bmp.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(size, image.size)
    }

    /* TODO: Support TIFF (low priority) */
    func testSingleTIF() {
        XCTAssertNotNil(self.dataSet.tif)
        let image: DataSet.Image = self.dataSet.tif.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery())
        /* Unsupported. Returns zero */
//        XCTAssertEqual(size, image.size)
        XCTAssertEqual(size, .zero)
    }

    func testSingleWebP() {
        XCTAssertNotNil(self.dataSet.webp)
        let image: DataSet.Image = self.dataSet.webp.first!
        let size: CGSize = ImageExtract().extract(image.url.withRandomQuery())
        XCTAssertEqual(size, image.size)
    }
}
