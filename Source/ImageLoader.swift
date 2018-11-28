//
//  ImageLoader.swift
//  ImageExtract
//
//  Created by kojirof on 2018/11/21.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

/**********************************************
 * ImageLoader
 **********************************************/
internal class ImageLoader {

    internal static var queues: [ImageLoaderQueue] = [ImageLoaderQueue]()

    internal static let defaultUserAgent: String = {
        #if os(macOS)
        return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
        #else
        return "Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1"
        #endif
    }()

    internal static var userAgent: String = defaultUserAgent {
        didSet { config.httpAdditionalHeaders = ["User-Agent": userAgent] }
    }

    internal static var config: URLSessionConfiguration = {
        var config: URLSessionConfiguration = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": userAgent]
        #if os(macOS)
        config.httpMaximumConnectionsPerHost = 6 /* System Default */
        #else
        config.httpMaximumConnectionsPerHost = 4 /* System Default */
        #endif
        config.timeoutIntervalForRequest = 60    /* System Default */
        return config
    }()

    internal static func request(_ request: ImageRequestConvertible) -> (data: Data?, response: URLResponse?, error: Error?) {
        guard let urlRequest: URLRequest = request.asURLRequest() else {
            return (nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
        let queue: ImageLoaderQueue = ImageLoaderQueue(urlRequest)
        return queue.start()
    }

    internal static func request(_ request: ImageRequestConvertible, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let urlRequest: URLRequest = request.asURLRequest() else {
            return completion(nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
        let queue: ImageLoaderQueue = ImageLoaderQueue(urlRequest)
        self.queues.append(queue)
        queue.start {
            removeQueue(request)
            completion($0, $1, $2)
        }
    }
}

/* Manage Queue */
internal extension ImageLoader {

    fileprivate static func getQueue(request: ImageRequestConvertible) -> ImageLoaderQueue? {
        return self.queues.filter { $0.request?.asURLString() == request.asURLString() }.first
    }

    internal static func cancelAllQueues() {
        if self.queues.count == 0 { return }
        tprint()
        tprint("⚠️ cancelAllQueue", "before", self.queues.count)
        self.queues.forEach { $0.cancel() }
        self.queues.removeAll()
        tprint("⚠️ cancelAllQueue", "after", self.queues.count)
    }

    internal static func cancelQueue(_ request: ImageRequestConvertible) {
        if self.queues.count == 0 { return }
        tprint()
        tprint("⚠️ cancelQueue", "before", self.queues.count)
        self.queues.filter { $0.request?.asURLString() == request.asURLString() }.forEach { $0.cancel() }
        removeQueue(request)
        tprint("⚠️ cancelQueue", "after", self.queues.count)
    }

    internal static func removeQueue(_ request: ImageRequestConvertible) {
        if self.queues.count == 0 { return }
        tprint()
        tprint("🗑️ removeQueue", "before", self.queues.count)
        for (i, queue): (Int, ImageLoaderQueue) in self.queues.reversed().enumerated() {
            if queue.isInvalidated {
                tprint("🗑️ removeQueue", "removing", "\(i)/\(self.queues.count)")
                self.queues.remove(safeAt: i)
            }
        }
        tprint("🗑️ removeQueue", "after", self.queues.count)
    }
}

/**********************************************
 * ImageLoaderQueue
 **********************************************/
internal class ImageLoaderQueue {

    /* Variables */
    var request: ImageRequestConvertible?
    var session: URLSession?
    var dataTask: URLSessionDataTask?

    enum State: Int {
        case running, suspended, canceling, completed, ready, invalidated
    }

    var state: State {
        guard let rawValue: Int = self.dataTask?.state.rawValue else { return State.invalidated }
        return State(rawValue: rawValue) ?? State.invalidated
    }

    var isInvalidated: Bool {
        return self.request == nil || self.dataTask == nil || self.state == State.invalidated || self.state == State.canceling || self.state == State.completed
    }

    /* Initialization */
    init(_ request: ImageRequestConvertible) {
        self.request = request
    }

    deinit {
        tprint("ImageLoaderQueue.deinit")
//        self.session?.invalidateAndCancel()
        self.dataTask = nil
        self.session = nil
        self.request = nil
    }

    /* Request */
    func start() -> (data: Data?, response: URLResponse?, error: Error?) {
        guard let urlRequest: URLRequest = self.request?.asURLRequest() else {
            return (nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
        self.session = URLSession(configuration: ImageLoader.config)
        let semaphore = DispatchSemaphore(value: 0)
        var result: (Data?, URLResponse?, Error?)
        self.session?.dataTask(with: urlRequest) {
            result = ($0, $1, $2)
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        self.session?.invalidateAndCancel()
        return result
    }

    func start(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let urlRequest: URLRequest = self.request?.asURLRequest() else {
            return completion(nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
        self.session = URLSession(configuration: ImageLoader.config)
        self.dataTask = self.session!.dataTask(with: urlRequest) {
            completion($0, $1, $2)
        }
        self.dataTask?.resume()
    }

    func cancel() {
        self.dataTask?.cancel()
        self.session?.invalidateAndCancel()
    }
}

/**
 A type that can be used to construct URL requests.
 [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to ImageRequestConvertible protocol.
 */
public protocol ImageRequestConvertible {
    /** Convert this value into a URLRequest object. */
    func asURLRequest() -> URLRequest?
    /** Convert this value into an absolute url string. */
    func asURLString() -> String?
}
