//
//  ImageExtract.swift
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
 Constants indicating chunk size of an image to download.<br/>
 The segment of JPG format has not fixed size because it has variable meta data. So you can specify the data size to be downloaded by passing chunk size as an argument.
 In most cases, you can get the size of an image with the initial value, but if you can not get the correct size, please specify a larger chunk size.
 */
public enum ImageChunkSize: Int {
    /** 100 Bytes */
    case small = 100
    /** 1,000 Bytes (1 Kilo Bytes) */
    case medium = 1000
    /** 10,000 Bytes (10 Kilo Bytes) */
    case large = 10000
    /** 50,000 Bytes (50 Kilo Bytes) */
    case extraLarge = 50000
    /** 100,000 Bytes (100 Kilo Bytes) */
    case huge = 100000
}

/**
 The class that allows you to get the size of a remote image without downloading.
 */
public class ImageExtract {

    /** An instance of ImageLoader */
    private var imageLoader: ImageLoader?

    /**
     A function to initialize instance.

     - Parameters:
       - userAgent: A String value to be set in the request header.
       - maxConnectionsPerHost: A Integer value that indicates the maximum number of simultaneous connections to make to a given host.
       - timeout: The timeout interval to use when waiting for additional data.
       - chunkSize: Chunk size limiting buffer size to be downloaded. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).extraLarge. (50,000 bytes)
     */
    public init(userAgent: String? = nil,
                maxConnectionsPerHost: Int = 0,
                timeout: TimeInterval = 5,
                chunkSize: ImageChunkSize = .extraLarge) {
        self.imageLoader = ImageLoader(
                userAgent: userAgent,
                maxConnectionsPerHost: maxConnectionsPerHost,
                timeout: timeout,
                chunkSize: chunkSize
        )
    }

    deinit {
        self.imageLoader = nil
    }

    /**
     A function to get the size of a remote image synchronously.

     - Parameters:
       - request: An image url to request. [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
     - Returns: A tuple value including image size and task result. If the session is cancelled or fails to extract the size of an image, the value of isFinished will be false.
     */
    public func extract(_ request: ImageRequestConvertible) -> (size: CGSize, isFinished: Bool) {
        /* Validate the request url */
        guard let urlRequest: URLRequest = request.asURLRequest() else { return (.zero, false) }
        /* Load image */
        return self.imageLoader!.request(urlRequest)
    }

    /**
     A function to get the size of a remote image asynchronously.

     - Parameters:
       - request: An image url to request. [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - completion: A handler that called when a request is completed. If the session is cancelled or fails to extract the size of an image, the value of isFinished will be false.
     */
    public func extract(_ request: ImageRequestConvertible,
                        completion: @escaping (String?, CGSize, Bool) -> Void) {
        /* Validate the request url */
        guard let urlRequest: URLRequest = request.asURLRequest() else {
            return completion(request.asURLString(), .zero, false)
        }
        /* Load image */
        self.imageLoader!.request(urlRequest, completion: completion)
    }
}

public extension ImageExtract {
    /**
     A function to get the size of an image with preferred width and max height.

     - Parameters:
       - request: An image url to request. [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - preferredWidth: A preferred width to resize.
       - maxHeight: A maximum height to be restricted at resizing.
     - Returns: A tuple value including image size and task result. If the session is cancelled or fails to extract the size of an image, the value of isFinished will be false.
     */
    public func extract(_ request: ImageRequestConvertible,
                        preferredWidth: CGFloat,
                        maxHeight: CGFloat = .greatestFiniteMagnitude) -> (size: CGSize, isFinished: Bool) {
        var result: (size: CGSize, isFinished: Bool) = self.extract(request)
        result.size = self.convertSize(size: result.size,
                                       preferredWidth: preferredWidth,
                                       maxHeight: maxHeight)
        return result
    }

    /**
     A function to get the size of an image with preferred width and max height.

     - Parameters:
       - request: An image url to request. [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - preferredWidth: A preferred width to resize.
       - maxHeight: A maximum height to be restricted at resizing.
       - completion: A handler that called when a request is completed. If the session is cancelled or fails to extract the size of an image, the value of isFinished will be false.
     */
    public func extract(_ request: ImageRequestConvertible,
                        preferredWidth: CGFloat,
                        maxHeight: CGFloat = .greatestFiniteMagnitude,
                        completion: @escaping (String?, CGSize, Bool) -> Void) {
        self.extract(request) { [weak self] (url: String?, size: CGSize, isFinished: Bool) in
            guard let `self`: ImageExtract = self else { return completion(nil, CGSize.zero, isFinished) }
            let size: CGSize = self.convertSize(size: size, preferredWidth: preferredWidth, maxHeight: maxHeight)
            completion(url, size, isFinished)
        }
    }

    /**
     A function to resize an image with preferred width and max height.

     - Parameters:
       - size: A size of an original image
       - preferredWidth: A preferred width to resize.
       - maxHeight: A maximum height to be restricted at resizing.
     - Returns: A size of a resized image.
     */
    private func convertSize(size: CGSize,
                             preferredWidth: CGFloat,
                             maxHeight: CGFloat) -> CGSize {
        if size.width == 0 || size.height == 0 { return .zero }
        return CGSize(width: round(preferredWidth),
                      height: round(min((size.height * preferredWidth) / size.width, maxHeight)))
    }
}

public extension ImageExtract {
    /** A Boolean value indicating whether download queues are running. */
    public var isQueueRunning: Bool {
        guard let imageLoader: ImageLoader = self.imageLoader else { return false }
        return imageLoader.isQueueRunning
    }

    /** A Integer value indicating the number of running queues. */
    public var queueCount: Int {
        guard let imageLoader: ImageLoader = self.imageLoader else { return 0 }
        return imageLoader.queueCount
    }

    /**
     A function to cancel all running queues.

     - Returns: A Boolean value indicating whether download queues are running.
    */
    @discardableResult
    public func cancelAllQueues() -> Bool {
        guard let imageLoader: ImageLoader = self.imageLoader else { return false }
        return imageLoader.cancelAllQueues()
    }

    /**
     A function to cancel a queue that contains a specific url.

     - Parameters:
       - request: An image url to request. [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
     - Returns: A Boolean value indicating whether download queues are running.
    */
    @discardableResult
    public func cancelQueue(request: ImageRequestConvertible) -> Bool {
        guard let imageLoader: ImageLoader = self.imageLoader else { return false }
        return imageLoader.cancelQueue(request)
    }
}
