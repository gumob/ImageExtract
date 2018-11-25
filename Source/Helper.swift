//
// Created by kojirof on 2018-11-22.
// Copyright (c) 2018 Gumob. All rights reserved.
//

import Foundation

internal extension Data {
    subscript<T>(start: Int, length: Int) -> T {
        return self[start..<start + length]
    }

    subscript<T>(range: Range<Data.Index>) -> T {
        return subdata(in: range).withUnsafeBytes { $0.pointee }
    }
}

/**
 Safe array get, set, insert and delete.
 All action that would cause an error are ignored.
 */
extension Array {

    /**
     Removes element at index.
     Action that would cause an error are ignored.
     */
    mutating func remove(safeAt index: Index) {
        guard index >= 0 && index < count else {
            print("Index out of bounds while deleting item at index \(index) in \(self). This action is ignored.")
            return
        }

        remove(at: index)
    }

//    /**
//     Inserts an element at index.
//     Action that would cause an error are ignored.
//     */
//    mutating func insert(_ element: Element, safeAt index: Index) {
//        guard index >= 0 && index <= count else {
//            print("Index out of bounds while inserting item at index \(index) in \(self). This action is ignored")
//            return
//        }
//
//        insert(element, at: index)
//    }
//
//    /**
//     Safe get set subscript.
//     Action that would cause an error are ignored.
//     */
//    subscript(safe index: Index) -> Element? {
//        get {
//            return indices.contains(index) ? self[index] : nil
//        }
//        set {
//            remove(safeAt: index)
//
//            if let element = newValue {
//                insert(element, safeAt: index)
//            }
//        }
//    }
}

/* For debugging */
//internal extension Int {
//    var hexString: String {
//        return String(format: "%02X", self)
//    }
//}
//
//internal extension UInt8 {
//    var char: Character {
//        return Character(UnicodeScalar(self))
//    }
//}

/* https://stackoverflow.com/a/51770616 */
//internal enum Bit: UInt8, CustomStringConvertible {
//    case zero, one
//
//    var description: String {
//        switch self {
//        case .one:
//            return "1"
//        case .zero:
//            return "0"
//        }
//    }
//}
//
//internal func bits<T: FixedWidthInteger>(fromBytes bytes: T) -> [Bit] {
//    /* Make variable */
//    var bytes: T = bytes
//    /* Fill an array of bits with zeros to the fixed width integer length */
//    var bits: [Bit] = [Bit](repeating: .zero, count: T.bitWidth)
//    /* Run through each bit (LSB first) */
//    for i in 0..<T.bitWidth {
//        let currentBit: T = bytes & 0x01
//        if currentBit != 0 {
//            bits[i] = .one
//        }
//        bytes >>= 1
//    }
//    return bits
//}
//
//internal extension FixedWidthInteger {
//    var bits: [Bit] {
//        /* Make variable */
//        var bytes: Self = self
//        /* Fill an array of bits with zeros to the fixed width integer length */
//        var bits: [Bit] = [Bit](repeating: .zero, count: self.bitWidth)
//        /* Run through each bit (LSB first) */
//        for i: Int in 0..<self.bitWidth {
//            let currentBit = bytes & 0x01
//            if currentBit != 0 {
//                bits[i] = .one
//            }
//            bytes >>= 1
//        }
//        return bits
//    }
//}
