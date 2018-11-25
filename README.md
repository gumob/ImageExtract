[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/gumob/ImageExtract)
[![Version](http://img.shields.io/cocoapods/v/ImageExtract.svg)](http://cocoadocs.org/docsets/ImageExtract)
[![Platform](http://img.shields.io/cocoapods/p/ImageExtract.svg)](http://cocoadocs.org/docsets/ImageExtract)
[![Build Status](https://travis-ci.com/gumob/ImageExtract.svg?branch=master)](https://travis-ci.com/gumob/ImageExtract)
[![codecov](https://codecov.io/gh/gumob/ImageExtract/branch/master/graph/badge.svg)](https://codecov.io/gh/gumob/ImageExtract)
![Language](https://img.shields.io/badge/Language-Swift%204.2-orange.svg)
![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)

# ImageExtract
A Swift library to allows you to extract the size of an image without downloading.

## Requirements

ImageExtract supports multiple platforms
- iOS 9.0 or later
- macOS 10.11 or later
- tvOS 10.0 or later
- watchOS 3.0 or later
- Swift 4.2

## Supported image format

- JPEG
- PNG
- GIF
- BMP
- WebP

## Installation

### Carthage

Add the following to your `Cartfile` and follow [these instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

```
github "gumob/ImageExtract"
```

### CocoaPods

To integrate ImageExtract into your project, add the following to your `Podfile`.

```ruby
platform :ios, '9.3'
use_frameworks!

pod 'ImageExtract'
```

## Usage

Read the [usage](https://gumob.github.io/ImageExtract/usage.html) and the [API reference]https://gumob.github.io/ImageExtract/Classes/ImageExtract.html) for detailed information.

### Initialization

Just import ImageExtract framework:
```swift
import ImageExtract
```

### Synchronous and asynchronous request

Get the size of an image synchronously:
```swift
let url: String = "https://example.com/image.jpg"
let size: CGSize = ImageExtract.extract(url)
print(size) // (800.0, 600.0)
```

Get the size of an image asynchronously:
```swift
let url: String = "https://example.com/image.jpg"
ImageExtract.extract(request) { (url: String?, size: CGSize) in
    print(size) // (800.0, 600.0)
}
```

## Copyright

ImageExtract is released under MIT license, which means you can modify it, redistribute it or use it however you like.
