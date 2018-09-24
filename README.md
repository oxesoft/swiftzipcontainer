# Swift Zip Container

This is an in-memory Zip container to add files and do whatever you want with the output (save to disk, stream from your webserver to the browser, etc).

usage:
```swift
let zip = ZipContainer()
zip.putNextEntry("emptyfile", Data())
zip.putNextEntry("example.txt", "some content\n".data(using: .utf8) ?? Data())
try? zip.getResult().write(to: URL(fileURLWithPath: "output.zip"))
```
