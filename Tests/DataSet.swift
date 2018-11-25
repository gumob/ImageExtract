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

struct DataSet: Codable {
    var jpg: [Image]
    var png: [Image]
    var gif: [Image]
    var tif: [Image]
    var bmp: [Image]
    var webp: [Image]
    var invalid_ext: [Image]

    struct Image: Codable {
        var url: String
        var size: CGSize
    }
}

internal extension String {

    func withRandomQuery() -> String {
        return "\(self)?rnd=\(UUID().uuidString.lowercased())"
    }
}

internal extension Bundle {
    class ClassForFramework {
    }

    static var current: Bundle {
        return Bundle.init(for: ClassForFramework.self)
    }
}
