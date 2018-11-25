# Usage

## Initialization

Just import ImageExtract framework
```swift
import ImageExtract
```

## Synchronous and asynchronous request

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

## Conform to ImageRequestConvertible

Request with String:
```swift
let url: String = "https://example.com/image.jpg"
ImageExtract.extract(request) { (url: String?, size: CGSize) in
    print(size) // (800.0, 600.0)
}
```

Request with URL:
```swift
let url: URL = URL(string: "https://example.com/image.jpg")
ImageExtract.extract(request) { (url: String?, size: CGSize) in
    print(size) // (800.0, 600.0)
}
```

Request with URLRequest:
```swift
let url: URL = URL(string: "https://example.com/image.jpg")!
let request: URLRequest = URLRequest(url: request)
ImageExtract.extract(request) { (url: String?, size: CGSize) in
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
for url: String in url {
    ImageExtract.extract(request, chunkSize: ImageChunkSize.large) { (url: String?, size: CGSize) in
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
for url: String in url {
    ImageExtract.extract(request, chunkSize: ImageChunkSize.large) { (url: String?, size: CGSize) in
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

Specify chunk size:
```swift
let url: String = "https://example.com/large-header-image.jpg"
ImageExtract.extract(request, chunkSize: ImageChunkSize.large) { (url: String?, size: CGSize) in
    print(size) // (800.0, 600.0)
}
```

Download all data including bitmap if it fails to extract the size of an image from chunk data:
```swift
let url: String = "https://example.com/large-header-image.jpg"
ImageExtract.extract(request, downloadOnFailure: true) { (url: String?, size: CGSize) in
    print(size) // (800.0, 600.0)
}
```

Get the resized size of an image with the desired width:
```swift
let url: String = "https://example.com/image.jpg" // Original size is (800.0, 600.0)
ImageExtract.extract(request, preferredWidth: 640) { (url: String?, size: CGSize) in
    print(size) // (640.0, 480.0)
}
```

Get the resized size of an image with the desired width restricting the maximum height:
```swift
let url: String = "https://example.com/image.jpg" // Original size is (800.0, 600.0)
ImageExtract.extract(request, preferredWidth: 640, maxHeight: 240) { (url: String?, size: CGSize) in
    print(size) // (320.0, 240.0)
}
```