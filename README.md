[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/gumob/ImageExtract)
[![Build Status](https://travis-ci.com/gumob/ImageExtract.svg?branch=master)](https://travis-ci.com/gumob/ImageExtract)
[![codecov](https://codecov.io/gh/gumob/ImageExtract/branch/master/graph/badge.svg)](https://codecov.io/gh/gumob/ImageExtract)
[![Platform](https://img.shields.io/badge/platform-ios%20|%20tvos%20|%20watchos%20|%20osx-lightgrey.svg)](https://github.com/gumob/ImageExtract)
![Language](https://img.shields.io/badge/Language-Swift%205.0-orange.svg)
![Language](https://img.shields.io/badge/Language-Swift%204.2-orange.svg)
![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg)

# ImageExtract
A Swift library to allows you to extract the size of an image without downloading.

## Requirements

ImageExtract supports multiple platforms
- iOS 10.0 or later
- macOS 10.11 or later
- Swift 5.0 ore later

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

Do not forget to include WebP.framework. Otherwise it will fail to build the application.<br/>

<img src="Metadata/carthage-xcode-config.jpg" alt="drawing" width="480" style="width:100%; max-width: 480px;"/>


<!--
### CocoaPods

To integrate ImageExtract into your project, add the following to your `Podfile`.

```ruby
platform :ios, '10.0'
use_frameworks!

pod 'ImageExtract'
```
-->

## Usage

Read the [usage](https://gumob.github.io/ImageExtract/usage.html) and the [API reference](https://gumob.github.io/ImageExtract/Classes/ImageExtract.html) for detailed information.

### Initialization

Just import ImageExtract framework:
```swift
import ImageExtract
```

### Synchronous and asynchronous request

Get the size of an image synchronously:
```swift
let url: String = "https://example.com/image.jpg"
let extractor: ImageExtract = ImageExtract()
let result: (size: CGSize, isFinished: Bool) = extractor.extract(url)
print(result.size) // (800.0, 600.0)
```

Get the size of an image asynchronously:
```swift
let url: String = "https://example.com/image.jpg"
let extractor: ImageExtract = ImageExtract()
extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

## Copyright

ImageExtract is released under MIT license, which means you can modify it, redistribute it or use it however you like.
