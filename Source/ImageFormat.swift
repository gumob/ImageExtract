//
// Created by kojirof on 2018-11-22.
// Copyright (c) 2018 Gumob. All rights reserved.
//

import Foundation

enum ImageFormat: UInt16 {

    case unknown = 0x0000
    case unsupported = 0x0001
    case jpg = 0xFFD8
    case png = 0x8950
    case gif = 0x4749
    case bmp = 0x424D
//    /* TODO: Support TIFF (low priority) */
//    case tif = 0x4949 /* Intel format */
//    case tiff = 0x4D4D /* Motorola format */
    case webp = 0x5249

    init(data: Data) {
        guard data.count >= 2 else {
            self = .unknown
            return
        }
        let header: UInt16 = CFSwapInt16(data[0..<2])
        if header == ImageFormat.webp.rawValue {
            let bytes: Data = data[8..<12]
            if let webp: String = String(data: bytes, encoding: .ascii)?.uppercased(), webp == "WEBP" {
                self = .webp
            } else {
                self = .unsupported
            }
        } else if let format: ImageFormat = ImageFormat(rawValue: header) {
            self = format
        } else {
            self = .unsupported
        }
    }

    var minimumLength: Int {
        switch self {
        case .jpg: return -1 /* The header size of jpg are variant. The size check is skipped */
        case .png: return 25
        case .gif: return 11
        case .bmp: return 29
//        /* TODO: Support TIFF (low priority) */
//        case .tif, .tiff: return 29
        case .webp: return 30
        default: return -1
        }
    }
}

enum ImageJPGFormat {
    case exif
    case jfif
    case unsupported

    init(data: Data) {
        guard data.count >= 10 else {
            self = .unsupported
            return
        }
        self = .unsupported
        let bytes: Data = data[6..<10]
        let meta: String = String(data: bytes, encoding: .ascii)!.uppercased()
        switch meta {
        case "EXIF": self = .exif
        case "JFIF": self = .jfif
        default:     self = .unsupported
        }
    }
}

enum ImageWebPFormat {
    case vp8x
    case vp8l
    case vp8
    case unsupported

    init(data: Data) {
        guard data.count >= 16 else {
            self = .unsupported
            return
        }
        self = .unsupported
        let bytes: Data = data[12..<16]
        let meta: String = String(data: bytes, encoding: .ascii)!.uppercased().replacingOccurrences(of: " ", with: "")
        switch meta {
        case "VP8X": self = .vp8x
        case "VP8L": self = .vp8l
        case "VP8":  self = .vp8
        default:     self = .unsupported
        }
    }
}
