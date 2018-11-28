//
//  ImageLoader.swift
//  ImageExtract
//
//  Created by kojirof on 2018/11/21.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

/* Load image */
internal class ImageLoader: URLSession {

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
        let session: URLSession = URLSession(configuration: config)
        let semaphore = DispatchSemaphore(value: 0)
        var result: (Data?, URLResponse?, Error?)
        session.dataTask(with: urlRequest) {
            result = ($0, $1, $2)
            semaphore.signal()
            session.invalidateAndCancel()
        }.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return result
    }

    internal static func request(_ request: ImageRequestConvertible, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let urlRequest: URLRequest = request.asURLRequest() else {
            return completion(nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
        let session: URLSession = URLSession(configuration: config)
        let dataTask: URLSessionDataTask = session.dataTask(with: urlRequest) {
            ImageLoader.invalidateQueue(request)
            completion($0, $1, $2)
            session.invalidateAndCancel()
        }
        let queue: ImageLoaderQueue = ImageLoader.addQueue(request, dataTask)
        queue.resume()
    }
}

internal extension ImageLoader {
    private static func addQueue(_ request: ImageRequestConvertible, _ dataTask: URLSessionDataTask) -> ImageLoaderQueue {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request, dataTask)
        self.queues.append(queue)
        return queue
    }

    private static func getQueue(request: ImageRequestConvertible) -> ImageLoaderQueue? {
        return self.queues.filter { $0.request?.asURLString() == request.asURLString() }.first
    }

//    private static func getQueue(dataTask: URLSessionDataTask) -> ImageLoaderQueue? {
//        return self.queues.filter { $0.dataTask == dataTask }.first
//    }

    internal static func cancelAllQueues() {
        if self.queues.count == 0 { return }
        print("⚠️ cancelAllQueue", "before", self.queues.count)
        self.queues.forEach { $0.cancel() }
        self.queues.removeAll()
        print("⚠️ cancelAllQueue", "after", self.queues.count)
    }

    internal static func cancelQueue(_ request: ImageRequestConvertible) {
        if self.queues.count == 0 { return }
        print("⚠️ cancelQueue", "before", self.queues.count)
        self.queues.filter { shouldRemove($0, request) }.forEach { $0.cancel() }
        removeQueue(request)
        print("⚠️ cancelQueue", "after", self.queues.count)
    }

    internal static func invalidateQueue(_ request: ImageRequestConvertible) {
        if self.queues.count == 0 { return }
        print("⚠️ invalidateQueue", "before", self.queues.count)
        getQueue(request: request)?.invalidate()
        removeQueue(request)
        print("⚠️ invalidateQueue", "after", self.queues.count)
    }

    internal static func removeQueue(_ request: ImageRequestConvertible) {
        if self.queues.count == 0 { return }
        print("🗑️ removeQueue", "before", self.queues.count)
//        let isEqual: (ImageLoaderQueue) -> Bool = { shouldRemove($0, request) }
//        self.queues.removeAll(where: isEqual)
        for (i, queue): (Int, ImageLoaderQueue) in self.queues.reversed().enumerated() {
            if shouldRemove(queue, request) {
                print("🗑️ removeQueue", "removing", "\(i)/\(self.queues.count)")
                self.queues.remove(safeAt: i)
            }
        }
        print("🗑️ removeQueue", "after", self.queues.count)
    }

    private static func shouldRemove(_ queue: ImageLoaderQueue, _ request: ImageRequestConvertible) -> Bool {
        guard let requestURL: String = request.asURLString() else { return false }
        /* If the queue is invalidated, the queue has been already cancelled */
        guard let queueURL: String = queue.request?.asURLString(), queue.isInvalidated == false else { return true }
        /* If the requested url matches the queue url, remove from the queue list */
        return requestURL == queueURL

    }
}

/* Queue */
internal class ImageLoaderQueue {

    enum State: Int {
        case running, suspended, canceling, completed, ready, invalidated
    }

    var state: State {
        guard let rawValue: Int = self.dataTask?.state.rawValue else { return State.invalidated }
        return State(rawValue: rawValue) ?? State.invalidated
    }

    var isInvalidated: Bool {
        return self.request == nil || self.dataTask == nil || self.state == State.invalidated
    }

    var request: ImageRequestConvertible?

    weak var dataTask: URLSessionDataTask?

    init(_ request: ImageRequestConvertible, _ dataTask: URLSessionDataTask) {
        self.request = request
        self.dataTask = dataTask
    }

    deinit {
        self.dataTask = nil
        self.request = nil
    }

    func resume() {
        self.dataTask?.resume()
    }

    func cancel() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.request = nil
    }

    func invalidate() {
        self.dataTask = nil
        self.request = nil
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
