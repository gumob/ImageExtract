import XCTest
#if os(OSX)
import AppKit
#else
import UIKit
#endif

@testable import ImageExtract

final class ImageExtractAsyncTests: XCTestCase {

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
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = "https://"
        ImageExtract.extract(request) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidURL2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = "localhost"
        ImageExtract.extract(request) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidURL3() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = ""
        ImageExtract.extract(request) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Invalid byte data */
    func testInvalidBytesJPG1() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG1")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-jfif-end.jpg"
        ImageExtract.extract(request, downloadOnFailure: true) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesJPG2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG2")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx.jpg"
        ImageExtract.extract(request, downloadOnFailure: true) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP1() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP1")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8-no-space.webp"
        ImageExtract.extract(request, downloadOnFailure: true) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG1")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8x-end.webp"
        ImageExtract.extract(request, downloadOnFailure: true) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP3() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP3")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-xxxx.webp"
        ImageExtract.extract(request) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP4() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP4")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-xxxx-vp8x.webp"
        ImageExtract.extract(request, downloadOnFailure: true) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP5() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP5")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-zero-byte.webp"
        ImageExtract.extract(request, downloadOnFailure: true) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Utility extension */
    func testUtilityExtension() {
        XCTAssertNotNil(self.dataSet.png)
        let exp: XCTestExpectation = expectation(description: "testUtilityExtension")
        XCTAssertNotNil(self.dataSet.png)
        let image: DataSet.Image = self.dataSet.png.first!
        ImageExtract.extract(image.url.withRandomQuery(), preferredWidth: 600) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, CGSize(width: 600, height: 399))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Single download */
    func testSinglePNG() {
        let exp: XCTestExpectation = expectation(description: "testSinglePNG")
        XCTAssertNotNil(self.dataSet.png)
        let image: DataSet.Image = self.dataSet.png.first!
        ImageExtract.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, image.size)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testSingleJPG() {
        let exp: XCTestExpectation = expectation(description: "testSingleJPG")
        XCTAssertNotNil(self.dataSet.jpg)
        let image: DataSet.Image = self.dataSet.jpg.first!
        ImageExtract.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, image.size)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testSingleGIF() {
        XCTAssertNotNil(self.dataSet.gif)
        let image: DataSet.Image = self.dataSet.gif.first!
        let size: CGSize = ImageExtract.extract(image.url.withRandomQuery())
        XCTAssertEqual(size, image.size)
    }

    func testSingleBMP() {
        let exp: XCTestExpectation = expectation(description: "testSingleBMP")
        XCTAssertNotNil(self.dataSet.bmp)
        let image: DataSet.Image = self.dataSet.bmp.first!
        ImageExtract.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, image.size)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* TODO: Support TIFF (low priority) */
//    func testSingleTIF() {
//        let exp: XCTestExpectation = expectation(description: "testSingleTIF")
//        XCTAssertNotNil(self.dataSet.tif)
//        let image: DataSet.Image = self.dataSet.tif.first!
//        ImageExtract.extract(image.url.withRandomQuery()) { (size: CGSize) in
//            XCTAssertEqual(size, image.size)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }

    func testSingleWebP() {
        let exp: XCTestExpectation = expectation(description: "testSingleWebP")
        XCTAssertNotNil(self.dataSet.webp)
        let image: DataSet.Image = self.dataSet.webp.first!
        ImageExtract.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize) in
            XCTAssertEqual(size, image.size)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Multiple download */
    func testMultipleJPGs() {
        let exp: XCTestExpectation = expectation(description: "testMultipleJPGs".withRandomQuery())
        XCTAssertNotNil(self.dataSet.jpg)
        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        for image: DataSet.Image in self.dataSet.jpg {
            let request: String = image.url.withRandomQuery()
            ImageExtract.extract(request) { (_: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, image.size)
                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testMultiplePNGs() {
        let exp: XCTestExpectation = expectation(description: "testMultiplePNGs".withRandomQuery())
        XCTAssertNotNil(self.dataSet.png)
        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        for image: DataSet.Image in self.dataSet.png {
            let request: String = image.url.withRandomQuery()
            ImageExtract.extract(request) { (_: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, image.size)
                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testMultipleGIFs() {
        let exp: XCTestExpectation = expectation(description: "testMultipleGIFs".withRandomQuery())
        XCTAssertNotNil(self.dataSet.gif)
        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        for image: DataSet.Image in self.dataSet.gif {
            let request: String = image.url.withRandomQuery()
            ImageExtract.extract(request) { (_: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, image.size)
                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testMultipleBMPs() {
        let exp: XCTestExpectation = expectation(description: "testMultipleBMPs".withRandomQuery())
        XCTAssertNotNil(self.dataSet.bmp)
        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        for image: DataSet.Image in self.dataSet.bmp {
            let request: String = image.url.withRandomQuery()
            ImageExtract.extract(request) { (_: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, image.size)
                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* TODO: Support TIFF (low priority) */
//    func testMultipleTIFs() {
//            let exp: XCTestExpectation = expectation(description: "testMultipleTIFs".withRandomQuery())
//            XCTAssertNotNil(self.dataSet.tif)
//            var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
//            for image: DataSet.Image in self.dataSet.tif {
//                let request: String = image.url.withRandomQuery()
//                ImageExtract.extract(request) { (_: String?, size: CGSize) in
//                    if isFulfilled { return } /* If unit test is already completed, do not proceed */
//                    XCTAssertEqual(size, image.size)
//                    if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
//                        isFulfilled = true
//                        exp.fulfill()
//                    }
//                }
//            }
//            wait(for: [exp], timeout: 120.0)
//    }

    func testMultipleWebPs() {
        let exp: XCTestExpectation = expectation(description: "testMultipleWebPs".withRandomQuery())
        XCTAssertNotNil(self.dataSet.webp)
        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        for image: DataSet.Image in self.dataSet.webp {
            let request: String = image.url.withRandomQuery()
            ImageExtract.extract(request) { (_: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, image.size)
                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Cancellation */
    func testRequestCancelAll() {
        let exp: XCTestExpectation = expectation(description: "testRequestCancelAll".withRandomQuery())
        XCTAssertNotNil(self.dataSet.bmp)

        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */

        /* Batch download */
        for image: DataSet.Image in self.dataSet.bmp {
            let request: String = image.url.withRandomQuery()
            ImageExtract.extract(request) { (url: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */

                tprint("👎", "queueCount:", ImageExtract.queueCount, "size", size)

                XCTAssertEqual(size, CGSize.zero)

                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }

        /* Remove all queues */
        tprint("🛑", "queueCount", "before", ImageExtract.queueCount)
        XCTAssertFalse(ImageExtract.cancelAllQueues())
        XCTAssertFalse(ImageExtract.isQueueRunning)
        XCTAssertEqual(ImageExtract.queueCount, 0)
        tprint("🛑️", "queueCount", "after", ImageExtract.queueCount)

        wait(for: [exp], timeout: 120.0)
    }

    func testRequestCancelURL() {
        let exp: XCTestExpectation = expectation(description: "testRequestCancelURL".withRandomQuery())
        XCTAssertNotNil(self.dataSet.bmp)

        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        let urlToCancel: String = self.dataSet.bmp.last!.url /* Url to cancel queue */

        /* Batch download */
        for image: DataSet.Image in self.dataSet.bmp {
            let request: String = image.url
            ImageExtract.extract(request) { (url: String?, size: CGSize) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */

                /* Assert image size */
                if url == urlToCancel {
                    XCTAssertEqual(size, CGSize.zero) /*　Cancelled queue returns zero */
                    tprint("👎", "queueCount:", ImageExtract.queueCount, "size", size)
                } else {
                    XCTAssertEqual(size, image.size)
                    tprint("👍️", "queueCount:", ImageExtract.queueCount, "size", size)
                }

                if ImageExtract.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    XCTAssertEqual(ImageExtract.queueCount, 0)
                    XCTAssertFalse(ImageExtract.isQueueRunning)
                    exp.fulfill()
                }
            }
        }

        /* Remove last queue */
        tprint("🛑", "queueCount", "before", ImageExtract.queueCount)
        XCTAssertTrue(ImageExtract.cancelQueue(request: urlToCancel))
        tprint("🛑️", "queueCount", "after", ImageExtract.queueCount)

        wait(for: [exp], timeout: 10.0)
    }
}
