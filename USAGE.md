# Usage

## Initialization

Just import ImageExtract framework:
```swift
import ImageExtract
```

## Synchronous and asynchronous request

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

## Conform to ImageRequestConvertible

Request with String:
```swift
let url: String = "https://example.com/image.jpg"
let extractor: ImageExtract = ImageExtract()
extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

Request with URL:
```swift
let url: URL = URL(string: "https://example.com/image.jpg")
let extractor: ImageExtract = ImageExtract()
extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

Request with URLRequest:
```swift
let url: URL = URL(string: "https://example.com/image.jpg")!
let request: URLRequest = URLRequest(url: request)
let extractor: ImageExtract = ImageExtract()
extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

## Cancel asynchronous requests
Create the list of urls:
```swift
let urls: [String] = [
    "https://example.com/image-0.jpg",
    "https://example.com/image-1.jpg",
    "https://example.com/image-2.jpg",
    "https://example.com/image-3.jpg",
    "https://example.com/image-4.jpg",
    "https://example.com/image-5.jpg",
]
```

Cancel all requests:
```swift
// Requests asynchronously
let extractor: ImageExtract = ImageExtract()
for url: String in url {
    extractor.extract(request, chunkSize: ImageChunkSize.large) { (url: String?, size: CGSize, isFinished: Bool) in
        print(size)  // (0.0, 0.0)
    }
}

// Cancel
print(ImageExtract.queueCount) // 6
ImageExtract.cancelAllQueues()
print(ImageExtract.queueCount) // 0
```
<font color="Red">If you cancel requests, a completion handler is called immediately and returns zero.</font>

Cancel a specific request:
```swift
// Requests asynchronously
let extractor: ImageExtract = ImageExtract()
for url: String in url {
    extractor.extract(request, chunkSize: ImageChunkSize.large) { (url: String?, size: CGSize, isFinished: Bool) in
        print(size) // (800.0, 600.0) or (0.0, 0.0)
    }
}

// Cancel
let urlToCancel: String = urls[3] // https://example.com/image-2.jpg
print(ImageExtract.queueCount) // 6
ImageExtract.cancelQueue(request: urlToCancel)
print(ImageExtract.queueCount) // 5
```
<font color="Red">If you cancel a request, a completion handler is called immediately and returns zero.</font>

## Extra arguments

Specify an user agent:
```swift
let url: String = "https://example.com/large-header-image.jpg"
let extractor: ImageExtract = ImageExtract(userAgent: "ImageExtract")
extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

Specify chunk size:
```swift
let url: String = "https://example.com/large-header-image.jpg"
let extractor: ImageExtract = ImageExtract(chunkSize: ImageChunkSize.large)
extractor.extract(request) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (800.0, 600.0)
}
```

Get the resized size of an image with the desired width:
```swift
let url: String = "https://example.com/image.jpg" // Original size is (800.0, 600.0)
let extractor: ImageExtract = ImageExtract()
extractor.extract(request, preferredWidth: 640) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (640.0, 480.0)
}
```

Get the resized size of an image with the desired width restricting the maximum height:
```swift
let url: String = "https://example.com/image.jpg" // Original size is (800.0, 600.0)
let extractor: ImageExtract = ImageExtract()
extractor.extract(request, preferredWidth: 640, maxHeight: 240) { (url: String?, size: CGSize, isFinished: Bool) in
    print(size) // (320.0, 240.0)
}
```