//
// Created by kojirof on 2018-11-23.
// Copyright (c) 2018 Gumob. All rights reserved.
//

import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif
import CoreGraphics
import WebP

internal class ImageDecoder {

    private var format: ImageFormat = .unknown

    /**
     A function to get chunk size synchronously.

     - Parameters:
       - request: An image url to request. [String](https://developer.apple.com/documentation/swift/string), [URL](https://developer.apple.com/documentation/foundation/url), and [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) are conform to [ImageRequestConvertible](../Protocols/ImageRequestConvertible.html) protocol.
       - chunkSize: Chunk size to download. The default value is [ImageChunkSize](../Enums/ImageChunkSize.html).small. (100 bytes)
     - Returns: (data, mimeType)
    */
    internal func decode(_ data: Data) -> CGSize? {
        var size: CGSize?
        switch self.format {
        case .unknown:
            self.format = ImageFormat(data: data)
            fallthrough
        case .jpg:
            size = JPGDecoder().getSize(data)
        case .png:
            size = PNGDecoder().getSize(data)
        case .gif:
            size = GIFDecoder().getSize(data)
        case .bmp:
            size = BMPDecoder().getSize(data)
//        /* TODO: Support TIFF (low priority) */
//        case .tif, .tiff:
//            size = TIFFDecoder().getSize(data)
        case .webp:
            size = WEBPDecoder().getSize(data)
        case .unsupported:
            size = .zero
        }
        return size
    }

}

internal class JPGDecoder {
    /**
     private function: getSize

     - Parameter
       - request: URL to request. String, URL, and URLRequest classes are conform to ImageRequestConvertible protocol
     - Returns: Image size

    * JPEG Specification
    * https://www.fileformat.info/format/jpeg/egff.htm
    * http://swag.outpostbbs.net/GRAPHICS/0143.PAS.html
    * http://www.fastgraph.com/help/jpeg_header_format.html
    */
    func getSize(_ data: Data) -> CGSize {
        switch ImageJPGFormat(data: data) {
        case .exif, .jfif:
            var i: Int = 4
            var blockLength: UInt16 = UInt16(data[i]) * 256 + UInt16(data[i + 1])
            repeat {
                i += Int(blockLength) /* Go to the next block */

                if i >= data.count { return .zero } /* Make sure that the index does not exceed the data size */

                if data[i] != 0xFF { return .zero } /* Check if the index is at the start of another block */

                /* If marker type is start of frame (SOF0, SOF1, or SOF2)
                   SOF marker contains image dimension */
                if 0xC0 <= data[i + 1] && data[i + 1] <= 0xC3 {
                    let h: UInt16 = data[i + 5, 2]
                    let w: UInt16 = data[i + 7, 2]
                    return CGSize(width: Int(CFSwapInt16(w)), height: Int(CFSwapInt16(h)))
                } else {
                    i += 2 /* Skip block marker */
                    blockLength = UInt16(data[i]) * 256 + UInt16(data[i + 1]) /* Go to the next block */
                }
            } while (i < data.count)

        default:
            return .zero

        }

        return .zero
    }
}

internal class PNGDecoder {
    /**
     private function: getSize

     - Parameter
       - request: URL to request. String, URL, and URLRequest classes are conform to ImageRequestConvertible protocol
     - Returns: Image size

     * PNG Specification
     * http://www.fileformat.info/format/png/corion.htm
     * https://www.w3.org/TR/PNG-Structure.html
     */
    func getSize(_ data: Data) -> CGSize {
        if data.count <= ImageFormat.png.minimumLength { return .zero }

        let w: UInt32 = data[16, 4]
        let h: UInt32 = data[20, 4]
        return CGSize(width: Int(CFSwapInt32(w)), height: Int(CFSwapInt32(h)))
    }
}

internal class GIFDecoder {
    /**
     private function: getGIFInfo

     - Parameter
       - request: URL to request. String, URL, and URLRequest classes are conform to ImageRequestConvertible protocol
     - Returns: Image size

     * GIF Specification
     * http://www.fileformat.info/format/gif/egff.htm
     * https://www.w3.org/Graphics/GIF/spec-gif87.txt
     */
    func getSize(_ data: Data) -> CGSize {
        if data.count <= ImageFormat.gif.minimumLength { return .zero }

        let w: UInt16 = data[6, 2]
        let h: UInt16 = data[8, 2]
        return CGSize(width: Int(w), height: Int(h))
    }
}

internal class BMPDecoder {
    /**
     private function: getSize

     - Parameter
       - request: URL to request. String, URL, and URLRequest classes are conform to ImageRequestConvertible protocol
     - Returns: Image size

     * BMP Specification
     * https://www.fileformat.info/format/bmp/egff.htm
     * http://www.fastgraph.com/help/bmp_header_format.html (Windows)
     * http://www.fastgraph.com/help/bmp_os2_header_format.html (OS2)
     */
    func getSize(_ data: Data) -> CGSize {
        if data.count <= ImageFormat.bmp.minimumLength { return .zero }

        let headerSize: UInt16 = data[14, 4] /* The size of BITMAPINFOHEADER structure (Win: 40, OS2: 12) */
        let offset: Int = headerSize == 40 ? 4 : 2
        let w: UInt32 = data[18, offset]
        let h: UInt32 = data[18 + offset, offset]
        return CGSize(width: Int(w), height: Int(h))
    }
}

/* TODO: Support TIFF (low priority) */
//internal class TIFFDecoder {
//    /**
//     private function: getSize
//
//     - Parameter
//       - request: URL to request. String, URL, and URLRequest classes are conform to ImageRequestConvertible protocol
//     - Returns: Image size
//
//     * TIFF Specification
//     * https://www.fileformat.info/format/tiff/egff.htm
//     */
//    func getSize(_ data: Data, _ format: ImageFormat) -> CGSize {
//        return .zero
//    }
//}

internal class WEBPDecoder {
    /**
     private function: getSize

     - Parameter
       - request: URL to request. String, URL, and URLRequest classes are conform to ImageRequestConvertible protocol
     - Returns: Image size

     * WebP Specification
     * https://developers.google.com/speed/webp/docs/riff_container
     * https://github.com/webmproject/libwebp/blob/master/src/dec/webp_dec.c
     * https://github.com/golang/image/blob/master/vp8l/decode.go
     */
    func getSize(_ data: Data) -> CGSize {
//        guard data.count > ImageFormat.webp.minimumLength,
//              let size: CGSize = try? WebPDecoder.decode(data, checkStatus: false) else { return .zero }
        guard data.count > ImageFormat.webp.minimumLength else { return .zero }
        let options = WebPDecoderOptions()
        let decoder = WebPDecoder()
        guard let image: CGImage = try? decoder.decode(data, options: options) else { return .zero }
        return CGSize(width: image.width, height: image.height)

        /* The current version uses libwebp static library. */
//        switch ImageWebPFormat(data: data) {
//        case .vp8x:
//            let w: UInt16 = data[24, 3]
//            let h: UInt16 = data[27, 3]
//            return CGSize(width: Int(w) + 1, height: Int(h) + 1)
//
//        case .vp8l:
//            let w: UInt16 = data[21, 2]
//            let h: UInt16 = data[23, 2]
//            return CGSize(width: Int(w), height: Int(h))
//
//        case .vp8:
//            let w: UInt16 = data[26, 2]
//            let h: UInt16 = data[28, 2]
//            return CGSize(width: Int(w), height: Int(h))
//
//        default:
//            return .zero
//
//        }
    }
}
