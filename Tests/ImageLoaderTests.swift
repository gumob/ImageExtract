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
//    func testInvalidURLSync1() {
//        let request: String = "https://"
//        let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader().request(request)
//        XCTAssertNil(result.data)
//        XCTAssertNil(result.response)
//        XCTAssertNotNil(result.error)
//    }
//
//    func testInvalidURLSync2() {
//        let request: String = "localhost"
//        let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader().request(request)
//        XCTAssertNil(result.data)
//        XCTAssertNil(result.response)
//        XCTAssertNotNil(result.error)
//    }
//
//    func testInvalidURLSync3() {
//        let request: String = ""
//        let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader().request(request)
//        XCTAssertNil(result.data)
//        XCTAssertNil(result.response)
//        XCTAssertNotNil(result.error)
//    }
//
//    func testInvalidURLAsync1() {
//        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
//        let request: String = "https://"
//        ImageLoader().request(request) { (data: Data?, response: URLResponse?, error: Error?) in
//            XCTAssertNil(data)
//            XCTAssertNil(response)
//            XCTAssertNotNil(error)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }
//
//    func testInvalidURLAsync2() {
//        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
//        let request: String = "localhost"
//        ImageLoader().request(request) { (data: Data?, response: URLResponse?, error: Error?) in
//            XCTAssertNil(data)
//            XCTAssertNil(response)
//            XCTAssertNotNil(error)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }
//
//    func testInvalidURLAsync3() {
//        let exp: XCTestExpectation = expectation(description: "testInvalidURLAsync")
//        let request: String = ""
//        ImageLoader().request(request) { (data: Data?, response: URLResponse?, error: Error?) in
//            XCTAssertNil(data)
//            XCTAssertNil(response)
//            XCTAssertNotNil(error)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }
//
//    /* Found & Not found */
//    func testRequestFoundSync() {
//        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
//        let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader().request(request)
//        XCTAssertEqual((result.response as? HTTPURLResponse)?.statusCode, 200)
//        XCTAssertNotNil(result.data)
//        XCTAssertNotNil(result.response)
//        XCTAssertNil(result.error)
//    }
//
//    func testRequestNotFoundSync() {
//        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/notfound.jpg"
//        let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader().request(request)
//        XCTAssertNotEqual((result.response as? HTTPURLResponse)?.statusCode, 200)
//    }
//
//    func testRequestFoundAsync() {
//        let exp: XCTestExpectation = expectation(description: "testRequestSuccessAsync")
//        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
//        ImageLoader().request(request) { (data: Data?, response: URLResponse?, error: Error?) in
//            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
//            XCTAssertNotNil(data)
//            XCTAssertNotNil(response)
//            XCTAssertNil(error)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }
//
//    func testRequestNotFoundAsync() {
//        let exp: XCTestExpectation = expectation(description: "testRequestFailureAsync")
//        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/notfound.jpg"
//        ImageLoader().request(request) { (_: Data?, response: URLResponse?, _: Error?) in
//            XCTAssertNotEqual((response as? HTTPURLResponse)?.statusCode, 200)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }
//
//    /* Duplicated request */
//    func testDuplicatedCallSync() {
//        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
//        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
//        _ = queue.start()
//        let result: (data: Data?, response: URLResponse?, error: Error?) = queue.start()
//        XCTAssertNotNil(result.error)
//
//    }
//
//    func testDuplicatedCallAsync() {
//        let exp: XCTestExpectation = expectation(description: "testDuplicatedRequestAsync")
//        let request: String = "https://raw.githubusercontent.com/gumob/ImageExtractTest/master/images/jpg/jpg-3d.jpg"
//        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
//        queue.start { _, _, _ in }
//        queue.start {
//            XCTAssertNotNil($2)
//            exp.fulfill()
//        }
//        wait(for: [exp], timeout: 120.0)
//    }

}
