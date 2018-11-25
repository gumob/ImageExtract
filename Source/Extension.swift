//
// Created by kojirof on 2018-11-25.
// Copyright (c) 2018 Gumob. All rights reserved.
//

import Foundation

extension String: ImageRequestConvertible {
    public func asURLRequest() -> URLRequest? {
        guard let url: URL = URL(string: self) else { return nil }
        return URLRequest(url: url)
    }
    public func asURLString() -> String? {
        return self
    }
}

extension URL: ImageRequestConvertible {
    public func asURLRequest() -> URLRequest? {
        return URLRequest(url: self)
    }
    public func asURLString() -> String? {
        return self.absoluteString
    }
}

extension URLRequest: ImageRequestConvertible {
    public func asURLRequest() -> URLRequest? {
        return self
    }
    public func asURLString() -> String? {
        return self.url?.absoluteString
    }
}
