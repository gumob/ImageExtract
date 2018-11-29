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
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidURL2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = "localhost"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidURL3() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = ""
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Invalid byte data */
    func testInvalidBytesJPG1() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG1")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-jfif-end.jpg"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesJPG2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG2")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx.jpg"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesJPG3() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG3")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/jpg-ffd8-xxxx-full.jpg"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP1() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP1")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8-no-space.webp"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesJPG1")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-vp8x-end.webp"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP3() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP3")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-webp-xxxx.webp"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP4() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP4")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-riff-xxxx-vp8x.webp"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
            XCTAssertEqual(size, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidBytesWEBP5() {
        let exp: XCTestExpectation = expectation(description: "testInvalidBytesWEBP5")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/invalid_bytedata/webp-zero-byte.webp"
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
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
        let extractor: ImageExtract = ImageExtract()
        let image: DataSet.Image = self.dataSet.png.first!
        extractor.extract(image.url.withRandomQuery(), preferredWidth: 600) { (_: String?, size: CGSize, _: Bool) in
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
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize, isFinished: Bool) in
            XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testSingleJPG() {
        let exp: XCTestExpectation = expectation(description: "testSingleJPG")
        XCTAssertNotNil(self.dataSet.jpg)
        let image: DataSet.Image = self.dataSet.jpg.first!
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize, isFinished: Bool) in
            XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testSingleGIF() {
        let exp: XCTestExpectation = expectation(description: "testSingleGIF")
        XCTAssertNotNil(self.dataSet.gif)
        let image: DataSet.Image = self.dataSet.bmp.first!
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize, isFinished: Bool) in
            XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testSingleBMP() {
        let exp: XCTestExpectation = expectation(description: "testSingleBMP")
        XCTAssertNotNil(self.dataSet.bmp)
        let image: DataSet.Image = self.dataSet.bmp.first!
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize, isFinished: Bool) in
            XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* TODO: Support TIFF (low priority) */
//    func testSingleTIF() {
//        let exp: XCTestExpectation = expectation(description: "testSingleTIF")
//        XCTAssertNotNil(self.dataSet.tif)
//        let image: DataSet.Image = self.dataSet.tif.first!
//        extractor.extract(image.url.withRandomQuery()) { (size: CGSize) in
//            XCTAssertEqual(size, image.size)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }

    func testSingleWebP() {
        let exp: XCTestExpectation = expectation(description: "testSingleWebP")
        XCTAssertNotNil(self.dataSet.webp)
        let image: DataSet.Image = self.dataSet.webp.first!
        let extractor: ImageExtract = ImageExtract()
        extractor.extract(image.url.withRandomQuery()) { (_: String?, size: CGSize, isFinished: Bool) in
            XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Multiple download */
    func testMultipleJPGs() {
        let exp: XCTestExpectation = expectation(description: "testMultipleJPGs".withRandomQuery())
        XCTAssertNotNil(self.dataSet.jpg)
        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        let extractor: ImageExtract = ImageExtract()
        for image: DataSet.Image in self.dataSet.jpg {
            let request: String = image.url.withRandomQuery()
            extractor.extract(request) { (_: String?, size: CGSize, isFinished: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
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
        let extractor: ImageExtract = ImageExtract()
        for image: DataSet.Image in self.dataSet.png {
            let request: String = image.url.withRandomQuery()
            extractor.extract(request) { (_: String?, size: CGSize, isFinished: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
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
        let extractor: ImageExtract = ImageExtract()
        for image: DataSet.Image in self.dataSet.gif {
            let request: String = image.url.withRandomQuery()
            extractor.extract(request) { (_: String?, size: CGSize, _: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, image.size)
                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
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
        let extractor: ImageExtract = ImageExtract()
        for image: DataSet.Image in self.dataSet.bmp {
            let request: String = image.url.withRandomQuery()
            extractor.extract(request) { (_: String?, size: CGSize, isFinished: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
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
//            let extractor: ImageExtract = ImageExtract()
//            for image: DataSet.Image in self.dataSet.tif {
//                let request: String = image.url.withRandomQuery()
//                extractor.extract(request) { (_: String?, size: CGSize, isFinished: Bool) in
//                    if isFulfilled { return } /* If unit test is already completed, do not proceed */
//                    XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
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
            let extractor: ImageExtract = ImageExtract()
            extractor.extract(request) { (_: String?, size: CGSize, isFinished: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */
                XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
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
        let extractor: ImageExtract = ImageExtract()

        /* Batch download */
        for image: DataSet.Image in self.dataSet.bmp {
            let request: String = image.url.withRandomQuery()
            extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */

                tprint("👎", "queueCount:", extractor.queueCount, "size", size)

                XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)

                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    exp.fulfill()
                }
            }
        }

        /* Remove all queues */
        tprint("🛑", "queueCount", "before", extractor.queueCount)
        let isRunning: Bool = extractor.cancelAllQueues()
        tprint("🛑", "isRunning", isRunning)
        XCTAssertFalse(isRunning)
        XCTAssertFalse(extractor.isQueueRunning)
        XCTAssertEqual(extractor.queueCount, 0)
        tprint("🛑️", "queueCount", "after", extractor.queueCount)

        wait(for: [exp], timeout: 120.0)
    }

    func testRequestCancelURL() {
        let exp: XCTestExpectation = expectation(description: "testRequestCancelURL".withRandomQuery())
        XCTAssertNotNil(self.dataSet.bmp)

        var isFulfilled: Bool = false /* Flag to avoid call fulfill repeatedly */
        let urlToCancel: String = self.dataSet.bmp.last!.url /* Url to cancel queue */

        let extractor: ImageExtract = ImageExtract()

        /* Batch download */
        for image: DataSet.Image in self.dataSet.bmp {
            let request: String = image.url
            extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
                if isFulfilled { return } /* If unit test is already completed, do not proceed */

                /* Assert image size */
                XCTAssertEqual(size, isFinished ? image.size : CGSize.zero)
//                if url == urlToCancel {
//                    XCTAssertEqual(size, CGSize.zero) /*　Cancelled queue returns zero */
//                    tprint("👎", "queueCount:", extractor.queueCount, "size", size)
//                } else {
//                    XCTAssertEqual(size, image.size)
//                    tprint("👍️", "queueCount:", extractor.queueCount, "size", size)
//                }

                if extractor.queueCount == 0 && !isFulfilled { /* If all queue is completed, complete unit test */
                    isFulfilled = true
                    XCTAssertEqual(extractor.queueCount, 0)
                    XCTAssertFalse(extractor.isQueueRunning)
                    exp.fulfill()
                }
            }
        }

        /* Remove last queue */
        tprint("🛑", "queueCount", "before", extractor.queueCount)
//        let queueCount: Int = extractor.queueCount
        XCTAssertTrue(extractor.cancelQueue(request: urlToCancel))
//        XCTAssertEqual(extractor.queueCount, queueCount - 1)
        XCTAssertTrue(extractor.isQueueRunning)
        tprint("🛑️", "queueCount", "after", extractor.queueCount)

        wait(for: [exp], timeout: 10.0)
    }
}
