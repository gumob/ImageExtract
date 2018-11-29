//
//  Error.swift
//  ImageExtract
//
//  Created by kojirof on 2018/11/23.
//  Copyright © 2018 Gumob. All rights reserved.
//

import Foundation

enum ImageExtractError: Error {
    case invalidUrl(message: String)
    case requestFailure(message: String)

//    static func == (lhs: ImageExtractError, rhs: ImageExtractError) -> Bool {
//        switch (lhs, rhs) {
//        case (.invalidUrl(let leftMessage), .invalidUrl(let rightMessage)):
//            return leftMessage == rightMessage
//        }
//    }
}
