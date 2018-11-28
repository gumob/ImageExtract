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

    internal static var imageQueues: [ImageLoaderQueue] = [ImageLoaderQueue]()

    private static let arrayAccessQueue = DispatchQueue(label: "ArrayAccessQueue", attributes: .concurrent)

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

}

/* Request */
internal extension ImageLoader {

    internal static func request(_ request: ImageRequestConvertible) -> (data: Data?, response: URLResponse?, error: Error?) {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        return queue.start()
    }

    internal static func request(_ request: ImageRequestConvertible, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        appendQueue(queue)
        queue.start {
            removeQueue(request)
            completion($0, $1, $2)
        }
    }

}

/* Manage Queue */
internal extension ImageLoader {

    /** A Boolean value indicating whether download imageQueues are running. */
    internal static var isQueueRunning: Bool {
        var result: Bool = false
        self.arrayAccessQueue.sync { result = imageQueues.count > 0 }
        return result
    }

    /** A Integer value indicating the number of running imageQueues. */
    internal static var queueCount: Int {
        var count: Int = 0
        self.arrayAccessQueue.sync { count = imageQueues.count }
        return count
    }

    internal static func appendQueue(_ queue: ImageLoaderQueue) {
        self.arrayAccessQueue.async(flags: .barrier) { imageQueues.append(queue) }
    }

    @discardableResult
    internal static func cancelAllQueues() -> Bool {
        self.arrayAccessQueue.async(flags: .barrier) {
            if self.imageQueues.count == 0 { return }
            tprint()
            tprint("⚠️ cancelAllQueue", "before", self.imageQueues.count)
            self.imageQueues.forEach { $0.cancel() }
            self.imageQueues.removeAll()
            tprint("⚠️ cancelAllQueue", "after", self.imageQueues.count)
        }
        return isQueueRunning
    }

    @discardableResult
    internal static func cancelQueue(_ request: ImageRequestConvertible) -> Bool {
        self.arrayAccessQueue.async(flags: .barrier) {
            if self.imageQueues.count == 0 { return }
            tprint()
            tprint("⚠️ cancelQueue", "before", self.imageQueues.count)
            self.imageQueues.filter { $0.request?.asURLString() == request.asURLString() }.forEach { $0.cancel() }
            removeQueue(request)
            tprint("⚠️ cancelQueue", "after", self.imageQueues.count)
        }
        return isQueueRunning
    }

    internal static func removeQueue(_ request: ImageRequestConvertible) {
        self.arrayAccessQueue.async(flags: .barrier) {
            if self.imageQueues.count == 0 { return }
            tprint()
            tprint("🗑️ removeQueue", "before", self.imageQueues.count)
            imageQueues.removeAll(where: {
                $0.isCancelled || $0.isFinished || $0.isInvalidated || $0.request?.asURLString() == request.asURLString()
            })
            tprint("🗑️ removeQueue", "after", self.imageQueues.count)
        }
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

    var _isCancelled: Bool = false
    var isCancelled: Bool { return self._isCancelled || self.state == State.canceling }

    var _isFinished: Bool = false
    var isFinished: Bool { return self._isFinished || self.state == State.completed }

    var isInvalidated: Bool { return self.request == nil || self.dataTask == nil || self.state == State.invalidated }

    /* Initialization */
    init(_ request: ImageRequestConvertible) {
        self.request = request
    }

    deinit {
        tprint("ImageLoaderQueue.deinit")
        self.session?.invalidateAndCancel()
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
        self.dataTask = self.session!.dataTask(with: urlRequest) { [weak self] in
            self?._isFinished = true
            completion($0, $1, $2)
        }
        self.dataTask?.resume()
    }

    func cancel() {
        self._isCancelled = true
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
