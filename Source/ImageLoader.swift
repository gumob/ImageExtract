//
//  ImageLoader.swift
//  ImageExtract
//
//  Created by kojirof on 2018/11/21.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

/**
 A class that can be used to manage queues loading data.
 */
internal class ImageLoader {

    /** Queues to store ImageLoaderQueue instances. */
    private var imageQueues: [ImageLoaderQueue] = [ImageLoaderQueue]()

    /** A queue to manipulate a thread-safe array. */
    private var arrayAccessQueue: DispatchQueue? = DispatchQueue(label: "com.gumob.ImageExtract.SynchronizedArray", attributes: .concurrent)

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

    deinit {
        self.arrayAccessQueue = nil
    }

}

/* Request */
internal extension ImageLoader {

    internal func request(_ request: ImageRequestConvertible) -> CGSize {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        return queue.start()
    }

    internal func request(_ request: ImageRequestConvertible, completion: @escaping (String?, CGSize) -> Void) {
        let queue: ImageLoaderQueue = ImageLoaderQueue(request)
        appendQueue(queue)
        queue.start { [weak self] in
            self?.removeQueue(request)
            completion($0, $1)
        }
    }

}

/* Manage Queue */
internal extension ImageLoader {

    /** A Boolean value indicating whether download imageQueues are running. */
    internal var isQueueRunning: Bool {
        var result: Bool = false
        self.arrayAccessQueue?.sync { [weak self] in
            guard let `self`: ImageLoader = self else { return }
            result = self.imageQueues.count > 0
        }
        return result
    }

    /** A Integer value indicating the number of running imageQueues. */
    internal var queueCount: Int {
        var count: Int = 0
        print("queueCount")
        print("self", self)
        self.arrayAccessQueue?.sync { [weak self] in
            guard let `self`: ImageLoader = self else { return }
            count = self.imageQueues.count
        }
        return count
    }

    internal func appendQueue(_ queue: ImageLoaderQueue) {
        self.arrayAccessQueue?.async(flags: .barrier) { [weak self] in
            guard let `self`: ImageLoader = self else { return }
            self.imageQueues.append(queue)
        }
    }

    @discardableResult
    internal func cancelAllQueues() -> Bool {
        self.arrayAccessQueue?.async(flags: .barrier) { [weak self] in
            guard let `self`: ImageLoader = self else { return }
            if self.imageQueues.count == 0 { return }
            self.imageQueues.forEach { $0.cancel() }
            self.imageQueues.removeAll()
        }
        return isQueueRunning
    }

    @discardableResult
    internal func cancelQueue(_ request: ImageRequestConvertible) -> Bool {
        self.arrayAccessQueue?.async(flags: .barrier) { [weak self] in
            guard let `self`: ImageLoader = self else { return }
            if self.imageQueues.count == 0 { return }
            self.imageQueues.filter { $0.request?.asURLString() == request.asURLString() }.forEach { $0.cancel() }
        }
        return self.isQueueRunning
    }

    internal func removeQueue(_ request: ImageRequestConvertible) {
        self.arrayAccessQueue?.async(flags: .barrier) { [weak self] in
            guard let `self`: ImageLoader = self else { return }
            if self.imageQueues.count == 0 { return }
            self.imageQueues.removeAll(where: {
                $0.state == .cancelled || $0.state == .failed || $0.state == .finished || $0.state == .invalidated || $0.request?.asURLString() == request.asURLString()
            })
        }
    }

}

/**
 A class that can be used to process request.
 */
internal class ImageLoaderQueue: NSObject {

    /** A instance of decoder */
    private var decoder: ImageDecoder?

    /** Partial data downloaded from host */
    private var buffer: Data = Data()

    /** A request url conforming ImageRequestConvertible */
    internal var request: ImageRequestConvertible?

    /** An instance of URLSession */
    internal var session: URLSession?

    /** An instance of URLSessionDataTask */
    internal var dataTask: URLSessionDataTask?

    /** A variable that can be used on synchronous request */
    var semaphore: DispatchSemaphore?

    /** A decoded size of an image */
    var decodedSize: CGSize = .zero

    /** A callback closure being called when an extraction is completed */
    typealias CompletionHandler = (String?, CGSize) -> Void
    var completionHandler: CompletionHandler?

    /** A result object being returned when an extraction is completed */
    var completionData: (Data?, URLResponse?, Error?)?

    /** An instance of URLSessionConfiguration containing unique parameters */
    internal lazy var config: URLSessionConfiguration! = {
        let config: URLSessionConfiguration = URLSessionConfiguration.ephemeral
        config.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        config.urlCredentialStorage = nil
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpAdditionalHeaders = ["User-Agent": ImageLoader.userAgent]
        config.httpMaximumConnectionsPerHost = ImageLoader.httpMaximumConnectionsPerHost
        config.timeoutIntervalForRequest = 5
        return config
    }()

    internal enum State: Int {
        case ready, running, cancelled, failed, finished, invalidated
    }

    /** A state indicating queue state */
    internal var state: State { return self._state }
    private var _state: State = .ready

//    /** A Boolean value indicating whether a queue is cancelled */
//    internal var isRunning: Bool { return self._isRunning || self.state == State.running }
//    private var _isRunning: Bool = false
//
//    /** A Boolean value indicating whether a queue is cancelled */
//    internal var isCancelled: Bool { return self._isCancelled || self.state == State.canceling }
//    private var _isCancelled: Bool = false
//
//    /** A Boolean value indicating whether a queue is failed */
//    internal var isFailed: Bool { return self._isFailed }
//    private var _isFailed: Bool = false
//
//    /** A Boolean value indicating whether a queue is finished */
//    internal var isFinished: Bool { return self._isFinished || self.state == State.finished }
//    private var _isFinished: Bool = false
//
//    /** A Boolean value indicating whether a queue is invalidated */
//    internal var isInvalidated: Bool { return self.request == nil || self.dataTask == nil || self.state == State.invalidated }

    /* Initialization */
    init(_ request: ImageRequestConvertible) {
        self.request = request
        self.decoder = ImageDecoder()
    }

    deinit {
        self.session?.finishTasksAndInvalidate()
        self.dataTask = nil
        self.session = nil
        self.request = nil
        self.semaphore = nil
        self.decoder = nil
    }

    /**
     A function to start a session synchronously

     - Returns: A tuple of URLResponse.
     */
    internal func start() -> CGSize {
        guard let urlRequest: URLRequest = self.request?.asURLRequest() else {
//            return (nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
            return .zero
        }
        guard self._state == .ready else {
//            return (nil, nil, ImageExtractError.requestFailure(message: "Session is already started."))
            return .zero
        }
        self.semaphore = DispatchSemaphore(value: 0)
        self.session = URLSession(configuration: self.config, delegate: self, delegateQueue: nil)
        self.dataTask = self.session?.dataTask(with: urlRequest)
        self._state = .running
        self.dataTask?.resume()
        self.session?.finishTasksAndInvalidate()
        _ = self.semaphore?.wait(timeout: .distantFuture)
        return self.decodedSize
    }

    /**
     A function to start a session asynchronously

     - Returns: A tuple of URLResponse.
     */
    internal func start(completion: @escaping (String?, CGSize) -> Void) {
        guard let urlRequest: URLRequest = self.request?.asURLRequest() else {
//            return completion(nil, nil, ImageExtractError.invalidUrl(message: "Invalid request url."))
            return completion(nil, .zero)
        }
        guard self._state == .ready else {
//            return completion(nil, nil, ImageExtractError.requestFailure(message: "Session is already started."))
            return completion(self.request?.asURLString(), .zero)
        }
        self.completionHandler = completion

        self.session = URLSession(configuration: self.config, delegate: self, delegateQueue: nil)
        self.dataTask = self.session?.dataTask(with: urlRequest)
        self._state = .running
        self.dataTask?.resume()
        self.session?.finishTasksAndInvalidate()
    }

    /**
     A function to cancel a asynchronous session
     */
    internal func cancel() {
        print("📈", "cancel", self.state)
        guard self._state == .ready || self._state == .running else { return }
        print("📈", "cancel", self.state)
        /* Switch state */
        self._state = .cancelled
        /* Finalize session */
        self.dataTask?.cancel()
        self.session?.invalidateAndCancel()
        /* Finish queue */
        self.finishQueue(size: .zero)
    }

    private func fail() {
        print("📈", "fail", self.state)
        guard self._state == .ready || self._state == .running else { return }
        print("📈", "fail", self.state)
        /* Switch state */
        self._state = .failed
        /* Finalize session */
        self.dataTask?.cancel()
        self.session?.invalidateAndCancel()
        /* Finish queue */
        self.finishQueue(size: .zero)
    }

    private func finish(size: CGSize) {
        print("📈", "finish", self.state)
        guard self._state == .ready || self._state == .running else { return }
        print("📈", "finish", self.state)
        /* Switch state */
        self._state = .finished
        /* Finalize session */
        self.dataTask?.cancel()
        self.session?.invalidateAndCancel()
        /* Finish queue */
        self.finishQueue(size: size)
    }

    private func finishQueue(size: CGSize) {
        if let completion: CompletionHandler = self.completionHandler {
            DispatchQueue.main.async { [weak self] in
                completion(self?.request?.asURLString(), size)
            }
        } else if let semaphore: DispatchSemaphore = self.semaphore {
            self.decodedSize = size
            semaphore.signal()
        }
    }

}

/* URLSessionDelegate */
extension ImageLoaderQueue: URLSessionDelegate {

//    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
//        print("📊", "didBecomeInvalidWithError", error)
//    }
//
//    func urlSession(_ session: URLSession,
//                    didReceive challenge: URLAuthenticationChallenge,
//                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("📊", "didReceive", challenge, completionHandler)
//    }

}

/* URLSessionDataDelegate */
extension ImageLoaderQueue: URLSessionDataDelegate {

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if self._state != .ready && self._state != .running {
            completionHandler(.cancel)
        } else if response.expectedContentLength >= 10 {
            completionHandler(.allow)
        } else {
            completionHandler(.cancel)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard self._state == .ready || self._state == .running else { return }
        guard let decoder: ImageDecoder = self.decoder else { return }
        self.buffer.append(data)
        if let size: CGSize = decoder.decode(self.buffer), size != .zero {
            self.finish(size: size)
        }
    }

    func urlSession(_ session: URLSession, task dataTask: URLSessionTask, didCompleteWithError error: Error?) {
        guard self._state == .ready || self._state == .running else { return }
        self.fail()
    }

//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
//        print("📊", "didBecome", "downloadTask")
//    }
//
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
//        print("📊", "didBecome", "streamTask")
//    }

//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
//        print("📊", "willCacheResponse", "proposedResponse")
//    }
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
