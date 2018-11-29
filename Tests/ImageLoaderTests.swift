import XCTest

@testable import ImageExtract

class ImageLoaderTests: XCTestCase {

    /* User Agent */
    func testUserAgent() {
        let ua: String = "User Agent"
        ImageLoader.userAgent = ua
        XCTAssertEqual(ImageLoader.userAgent, ua)
    }

    /* ImageRequestConvertible */
    func testImageRequestConvertible() {
        let str: String? = "https://github.com"
        XCTAssertNotNil(str?.asURLRequest())
        XCTAssertEqual(str?.asURLString(), str)

        let url: URL? = URL(string: str!)
        XCTAssertNotNil(url?.asURLRequest())
        XCTAssertEqual(url?.asURLString(), str)

        let urlRequest: URLRequest? = URLRequest(url: url!)
        XCTAssertNotNil(urlRequest?.asURLRequest())
        XCTAssertEqual(urlRequest?.asURLString(), str)
    }

    /* Invalid URL */
    func testInvalidURLSync1() {
        let request: String = "https://"
        let size: CGSize = ImageLoader().request(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidURLSync2() {
        let request: String = "localhost"
        let size: CGSize = ImageLoader().request(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidURLSync3() {
        let request: String = ""
        let size: CGSize = ImageLoader().request(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testInvalidURLAsync1() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = "https://"
        ImageLoader().request(request) {
            XCTAssertEqual($1, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidURLAsync2() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = "localhost"
        ImageLoader().request(request) {
            XCTAssertEqual($1, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testInvalidURLAsync3() {
        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
        let request: String = ""
        ImageLoader().request(request) {
            XCTAssertEqual($1, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Found & Not found */
    func testRequestFoundSync() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
        let size: CGSize = ImageLoader().request(request)
        XCTAssertNotEqual(size, CGSize.zero)
    }

    func testRequestNotFoundSync() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/notfound.jpg"
        let size: CGSize = ImageLoader().request(request)
        XCTAssertEqual(size, CGSize.zero)
    }

    func testRequestFoundAsync() {
        let exp: XCTestExpectation = expectation(description: "testRequestSuccessAsync")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
        ImageLoader().request(request) {
            XCTAssertNotEqual($1, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    func testRequestNotFoundAsync() {
        let exp: XCTestExpectation = expectation(description: "testRequestFailureAsync")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/notfound.jpg"
        ImageLoader().request(request) {
            XCTAssertEqual($1, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

    /* Duplicated request */
    func testDuplicatedCallSync() {
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        _ = queue.start()
        let size: CGSize = queue.start()
        XCTAssertEqual(size, CGSize.zero)

    }

    func testDuplicatedCallAsync() {
        let exp: XCTestExpectation = expectation(description: "testDuplicatedRequestAsync")
        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        queue.start { _, _ in }
        queue.start {
            XCTAssertEqual($1, CGSize.zero)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 120.0)
    }

}
