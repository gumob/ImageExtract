//
//  ImageLoader.swift
//  ImageExtract
//
//  Created by kojirof on 2018/11/21.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

/**
 A class that can be used to manage queues loading data.
 */
internal class ImageLoader {

    /** Queues to store ImageLoaderQueue instances. */
    private var imageQueues: [ImageLoaderQueue] = [ImageLoaderQueue]()

    /** A queue to manipulate a thread-safe array. */
    private let arrayAccessQueue = DispatchQueue(label: "com.gumob.ImageExtract.SynchronizedArray", attributes: .concurrent)

    /** A browser user agent */
    internal static var userAgent: String = {
        #if os(macOS)
        return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9"
        #else
        return "Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1"
        #endif
    }()

    /** The maximum number of simultaneous connections to make to a given host. */
    internal static var httpMaximumConnectionsPerHost: Int = {
        #if os(macOS)
        return 6
        #else
        return 4
        #endif
    }()

    init() {
    }

}

/* Request */
internal extension ImageLoader {

    internal func request(_ request: ImageRequestConvertible) -> (data: Data?, response: URLResponse?, error: Error?) {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        return queue.start()
    }

    internal func request(_ request: ImageRequestConvertible, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        appendQueue(queue)
        queue.start {
            self.removeQueue(request)
            completion($0, $1, $2)
        }
    }

}

/* Manage Queue */
internal extension ImageLoader {

    /** A Boolean value indicating whether download imageQueues are running. */
    internal var isQueueRunning: Bool {
        var result: Bool = false
        self.arrayAccessQueue.sync { result = self.imageQueues.count > 0 }
        return result
    }

    /** A Integer value indicating the number of running imageQueues. */
    internal var queueCount: Int {
        var count: Int = 0
        self.arrayAccessQueue.sync { count = self.imageQueues.count }
        return count
    }

    internal func appendQueue(_ queue: ImageLoaderQueue) {
        self.arrayAccessQueue.async(flags: .barrier) { self.imageQueues.append(queue) }
    }

    @discardableResult
    internal func cancelAllQueues() -> Bool {
        self.arrayAccessQueue.async(flags: .barrier) {
            if self.imageQueues.count == 0 { return }
            self.imageQueues.forEach { $0.cancel() }
            self.imageQueues.removeAll()
        }
        return isQueueRunning
    }

    @discardableResult
    internal func cancelQueue(_ request: ImageRequestConvertible) -> Bool {
        self.arrayAccessQueue.async(flags: .barrier) {
            if self.imageQueues.count == 0 { return }
            self.imageQueues.filter { $0.request?.asURLString() == request.asURLString() }.forEach { $0.cancel() }
            self.removeQueue(request)
        }
        return self.isQueueRunning
    }

    internal func removeQueue(_ request: ImageRequestConvertible) {
        self.arrayAccessQueue.async(flags: .barrier) {
            if self.imageQueues.count == 0 { return }
            self.imageQueues.removeAll(where: {
                $0.isCancelled || $0.isFinished || $0.isInvalidated || $0.request?.asURLString() == request.asURLString()
            })
        }
    }

}

/**
 A class that can be used to process request.
 */
internal class ImageLoaderQueue {

    /** A request url conforming ImageRequestConvertible */
    internal var request: ImageRequestConvertible?
    /** An instance of URLSession containing unique parameters */
    internal var session: URLSession? = {
        var config: URLSessionConfiguration = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": ImageLoader.userAgent]
        config.httpMaximumConnectionsPerHost = ImageLoader.httpMaximumConnectionsPerHost
        return URLSession(configuration: config)
    }()
    /** An instance of URLSessionDataTask */
    internal var dataTask: URLSessionDataTask?

    internal enum State: Int {
        case running, suspended, canceling, completed, ready, invalidated
    }

    /** A state conforming URLSessionDataTask.State */
    internal var state: State {
        guard let rawValue: Int = self.dataTask?.state.rawValue else { return State.invalidated }
        return State(rawValue: rawValue) ?? State.invalidated
    }

    /** A flag indicating whether a queue is cancelled */
    internal var isCancelled: Bool { return self._isCancelled || self.state == State.canceling }
    private var _isCancelled: Bool = false

    /** A flag indicating whether a queue is finished */
    internal var isFinished: Bool { return self._isFinished || self.state == State.completed }
    private var _isFinished: Bool = false

    /** A flag indicating whether a queue is invalidated */
    internal var isInvalidated: Bool { return self.request == nil || self.dataTask == nil || self.state == State.invalidated }

    /* Initialization */
    init(_ request: ImageRequestConvertible) {
        self.request = request
    }

    deinit {
        self.session?.invalidateAndCancel()
        self.dataTask = nil
        self.session = nil
        self.request = nil
    }

    /**
     A function to start a session synchronously

     - Returns: A tuple of URLResponse.
     */
    internal func start() -> (data: Data?, response: URLResponse?, error: Error?) {
        guard let urlRequest: URLRequest = self.request?.asURLRequest() else {
            return (nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
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

    /**
     A function to start a session asynchronously

     - Returns: A tuple of URLResponse.
     */
    internal func start(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let urlRequest: URLRequest = self.request?.asURLRequest() else {
            return completion(nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
        }
        self.dataTask = self.session!.dataTask(with: urlRequest) { [weak self] in
            self?._isFinished = true
            completion($0, $1, $2)
        }
        self.dataTask?.resume()
    }

    /**
     A function to cancel a asynchronous session
     */
    internal func cancel() {
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
