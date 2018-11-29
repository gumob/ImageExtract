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

    /**
     A function to get the size of a remote image synchronously.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
       - downloadOnFailure: A Boolean value indicating whether all data including bitmap should be downloaded if it fails to extract an image size from chunk data. The default value is false.
     - Returns: A size of an image.
     */
    public class func extract(_ request: ImageRequestConvertible,
                              chunkSize: ImageChunkSize = .small,
                              downloadOnFailure: Bool = false) -> CGSize {
        /* Validate the request url */
        guard let request: URLRequest = request.asURLRequest() else { return .zero }
        /* Get chunk data */
        let chunk: (data: Data?, format: ImageFormat) = self.getChunk(request, chunkSize)
        /* Decode the image size */
        guard let data: Data = chunk.data else { return .zero }
        return getSize(data, chunk.format, request, downloadOnFailure)
    }

    /**
     A function to get the size of a remote image asynchronously.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
       - downloadOnFailure: A Boolean value indicating whether all data including bitmap should be downloaded if it fails to extract an image size from chunk data. The default value is false.
       - completion: A handler that called when a request is completed.
     */
    public class func extract(_ request: ImageRequestConvertible,
                              chunkSize: ImageChunkSize = .small,
                              downloadOnFailure: Bool = false,
                              completion: @escaping (String?, CGSize) -> Void) {
        /* Validate the request url */
        guard let urlRequest: URLRequest = request.asURLRequest() else {
            return completion(request.asURLString(), .zero)
        }
        getChunk(urlRequest, chunkSize) { (data: Data?, format: ImageFormat) in
            /* Get chunk data */
            guard let data: Data = data, format != .unsupported else {
                return completion(request.asURLString(), .zero)
            }
            /* Decode the image size */
            getSize(data, format, urlRequest, downloadOnFailure) { (size: CGSize) in
                completion(urlRequest.asURLString(), size)
            }
        }
    }
}

private extension ImageExtract {
    /**
     A function to get chunk size synchronously.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
     - Returns: (data, mimeType)
    */
    private class func getChunk(_ request: URLRequest, _ chunkSize: ImageChunkSize) -> (data: Data?, format: ImageFormat) {
        /* Add bytes range to the request header */
        var request: URLRequest = request
        request.setValue("bytes=0-\(chunkSize)", forHTTPHeaderField: "Range")

        /* Retrieve chunk */
        let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader.request(request)

        /* If an error occurs, just return */
        if let _: Error = result.error { return (nil, .unsupported) }
        guard let data: Data = result.data else { return (nil, .unsupported) }

        /* Detect the image format from data */
        let format: ImageFormat = ImageFormat(data: data)
        return (data, format)
    }

    /**
     A function to get chunk size asynchronously.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
       - completion: A handler that called when image size extraction is completed.
     - Returns: (data, mimeType)
    */
    private class func getChunk(_ request: URLRequest, _ chunkSize: ImageChunkSize, _ completion: @escaping (Data?, ImageFormat) -> Void) {
        /* Add bytes range to the request header */
        var request: URLRequest = request
        request.setValue("bytes=0-\(chunkSize)", forHTTPHeaderField: "Range")

        /* Retrieve chunk */
        ImageLoader.request(request) { (data: Data?, _: URLResponse?, error: Error?) in
            /* If an error occurs, just return */
            guard let data: Data = data, error == nil else {
                return completion(nil, ImageFormat.unsupported)
            }
            /* Detect the image format from data */
            let format: ImageFormat = ImageFormat(data: data)
            completion(data, format)
        }
    }
}

private extension ImageExtract {
    /**
     A function to get the size of an image from chunk data synchronously.

     - Parameters:
       - data: Small data containing header information of a image.
       - format: The format of a downloaded image.
       - request: An image url to request.
       - downloadOnFailure: A Boolean value indicating whether all data including bitmap should be downloaded if it fails to extract an image size from chunk data. The default value is false.
     - Returns: (data, mimeType)
     */
    private class func getSize(_ data: Data,
                               _ format: ImageFormat,
                               _ request: URLRequest,
                               _ downloadOnFailure: Bool = false) -> CGSize {
        let size: CGSize = decodeSizeFromChunk(data, format)

        /* If extraction fails, download entire image */
        if size.equalTo(.zero) && downloadOnFailure {
            let result: (data: Data?, response: URLResponse?, error: Error?) = ImageLoader.request(request)
            guard let data: Data = result.data else { return size }

            return decodeSizeFromImage(data)
        }

        return size
    }

    /**
     A function to get the size of an image from chunk data asynchronously.

     - Parameters:
       - data: Small data containing header information of a image.
       - format: The format of a downloaded image.
       - request: An image url to request.
       - downloadOnFailure: A Boolean value indicating whether all data including bitmap should be downloaded if it fails to extract an image size from chunk data. The default value is false.
     */
    private class func getSize(_ data: Data,
                               _ format: ImageFormat,
                               _ request: URLRequest,
                               _ downloadOnFailure: Bool = false,
                               _ completion: @escaping (CGSize) -> Void) {
        let size: CGSize = decodeSizeFromChunk(data, format)

        /* If extraction fails, download entire image */
        if size.equalTo(.zero) && downloadOnFailure {
            ImageLoader.request(request) { (data: Data?, _: URLResponse?, error: Error?) in
                guard let data: Data = data, error == nil else { return completion(.zero) }
                completion(decodeSizeFromImage(data))
            }
        } else {
            completion(size)
        }
    }

    /**
     A function to get the size from chunk data.

     - Parameters:
       - data: Small data containing header information of a image.
       - format: The format of a downloaded image.
     - Returns: (data, mimeType)
     */
    private class func decodeSizeFromChunk(_ data: Data, _ format: ImageFormat) -> CGSize {
        var size: CGSize = .zero

        /* Extract image dimension */
        switch format {
        case .png:
            size = PNGDecoder().getSize(data)
        case .gif:
            size = GIFDecoder().getSize(data)
        case .jpg:
            size = JPGDecoder().getSize(data)
        case .bmp:
            size = BMPDecoder().getSize(data)
                /* TODO: Support TIFF (low priority) */
//        case .tif, .tiff:
//            size = TIFFDecoder.getSize(data, chunk.format)
        case .webp:
            let webpFormat: ImageWebPFormat = ImageWebPFormat(data: data)
            switch webpFormat {
            case .vp8x, .vp8l, .vp8:
                size = WEBPDecoder().getSize(data)
            case .unsupported:
                break
            }

        default:
            break
        }

        return size
    }

    /*
     A function to get size from data including bitmap.

     - Parameters:
       - data: Small data containing header information of a image.
     - Returns: A size of an image
     */
    private class func decodeSizeFromImage(_ data: Data) -> CGSize {
        #if os(OSX)
        if let image: NSImage = NSImage(data: data) { return image.size }
        #else
        if let image: UIImage = UIImage(data: data) { return image.size }
        #endif
        return .zero
    }
}

public extension ImageExtract {
    /**
     A function to get the size of an image with preferred width and max height.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - preferredWidth: A preferred width to resize.
       - maxHeight: A maximum height to be restricted at resizing.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
       - downloadOnFailure: A Boolean value indicating whether all data including bitmap should be downloaded if it fails to extract an image size from chunk data. The default value is false.
     - Returns: A size of an image.
     */
    public static func extract(_ request: ImageRequestConvertible,
                               preferredWidth: CGFloat,
                               maxHeight: CGFloat = .greatestFiniteMagnitude,
                               chunkSize: ImageChunkSize = .small,
                               downloadOnFailure: Bool = false) -> CGSize {
        return self.convertSize(size: self.extract(request, chunkSize: chunkSize, downloadOnFailure: downloadOnFailure),
                                preferredWidth: preferredWidth,
                                maxHeight: maxHeight)
    }

    /**
     A function to get the size of an image with preferred width and max height.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - preferredWidth: A preferred width to resize.
       - maxHeight: A maximum height to be restricted at resizing.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
       - downloadOnFailure: A Boolean value indicating whether all data including bitmap should be downloaded if it fails to extract an image size from chunk data. The default value is false.
       - completion: A handler that called when a request is completed.
     */
    public static func extract(_ request: ImageRequestConvertible,
                               preferredWidth: CGFloat,
                               maxHeight: CGFloat = .greatestFiniteMagnitude,
                               chunkSize: ImageChunkSize = .small,
                               downloadOnFailure: Bool = false,
                               completion: @escaping (String?, CGSize) -> Void) {
        self.extract(request, chunkSize: chunkSize, downloadOnFailure: downloadOnFailure) { (url: String?, size: CGSize) in
            let size: CGSize = self.convertSize(size: size, preferredWidth: preferredWidth, maxHeight: maxHeight)
            completion(url, size)
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
    private static func convertSize(size: CGSize,
                                    preferredWidth: CGFloat,
                                    maxHeight: CGFloat) -> CGSize {
        if size.width == 0 || size.height == 0 { return .zero }
        return CGSize(width: round(preferredWidth),
                      height: round(min((size.height * preferredWidth) / size.width, maxHeight)))
    }
}

/* Configuration */
public extension ImageExtract {
    /** A String value to be set in the request header. */
    public static var userAgent: String {
        set { ImageLoader.userAgent = newValue }
        get { return ImageLoader.userAgent }
    }
    /** A Integer value that indicates the maximum number of simultaneous connections to make to a given host. */
    public static var maxConnectionsPerHost: Int {
        set { ImageLoader.httpMaximumConnectionsPerHost = newValue }
        get { return ImageLoader.httpMaximumConnectionsPerHost }
    }
}

public extension ImageExtract {
    /** A Boolean value indicating whether download queues are running. */
    public static var isQueueRunning: Bool { return ImageLoader.isQueueRunning }

    /** A Integer value indicating the number of running queues. */
    public static var queueCount: Int { return ImageLoader.queueCount }

    /**
     A function to cancel all running queues.

     - Returns: A Boolean value indicating whether download queues are running.
    */
    @discardableResult
    public static func cancelAllQueues() -> Bool { return ImageLoader.cancelAllQueues() }

    /**
     A function to cancel a queue that contains a specific url.

     - Parameters:
       - request: An image url to request.  [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
     - Returns: A Boolean value indicating whether download queues are running.
    */
    @discardableResult
    public static func cancelQueue(request: ImageRequestConvertible) -> Bool { return ImageLoader.cancelQueue(request) }
}
