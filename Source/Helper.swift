//
// Created by kojirof on 2018-11-22.
// Copyright (c) 2018 Gumob. All rights reserved.
//

import Foundation

/**
 print function that print message on only an unit test
 */
internal var isTestRunning: Bool = NSClassFromString("XCTest") != nil

internal func tprint(_ items: Any...) {
    if !isTestRunning { return }
    print(items.map { String(describing: $0) }.joined(separator: " "))
}

/**
 Subscript data
 */
internal extension Data {
    subscript<T>(start: Int, length: Int) -> T {
        return self[start..<start + length]
    }

    subscript<T>(range: Range<Data.Index>) -> T {
        return subdata(in: range).withUnsafeBytes { $0.pointee }
    }
}
