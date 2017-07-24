<p align="center">
    <img src="https://user-images.githubusercontent.com/7799382/28500818-232faee0-6f84-11e7-9f4f-71ba89c8122e.png" alt="Disk" />
</p>

<p align="center">
    <img src="https://user-images.githubusercontent.com/7799382/28500846-b53d3960-6f84-11e7-9f4b-164133170283.png" alt="Platform: iOS 10+" />
    <a href="https://developer.apple.com/swift" target="_blank"><img src="https://user-images.githubusercontent.com/7799382/28500845-b43a66fa-6f84-11e7-8281-6e689d8aaab9.png" alt="Language: Swift 4" /></a>
    <a href="https://cocoapods.org/pods/Disk" target="_blank"><img src="https://user-images.githubusercontent.com/7799382/28500848-b7b2278c-6f84-11e7-90e5-778168a9e569.png" alt="CocoaPods compatible" /></a>
    <img src="https://user-images.githubusercontent.com/7799382/28500847-b6393648-6f84-11e7-9a7a-f6ae78207416.png" alt="License: MIT" />
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#debugging">Debugging</a>
  • <a href="#license">License</a>
  • <a href="#contribute">Contribute</a>
</p>

Disk is a **powerful** and **simple** file management library built with <a href="https://developer.apple.com/icloud/documentation/data-storage/index.html" target="_blank">Apple's Data Storage guidelines</a> in mind. Disk uses the new `Codable` protocol introduced in Swift 4 to its utmost advantage and gives you the power to persist JSON data without ever having to worry about encoding/decoding. Disk also helps you store images and other data types to disk with as little as one line of code.

## Compatibility

Disk requires **iOS 10+** and is compatible with **Swift 4** projects.

## Installation

* Installation for <a href="https://guides.cocoapods.org/using/using-cocoapods.html" target="_blank">CocoaPods</a>:

```ruby
platform :ios, '10.0'
target 'ProjectName' do
use_frameworks!

    pod 'Disk'

end
```
* Or embed the Disk framework into your project

And `import Disk` in the files you'd like to use it.

## Usage

Disk currently supports file management of the following types:

* `Codable`
* `[Codable]`
* `UIImage`
* `[UIImage]`
* `Data`
* `[Data]`

*These are generally the only types you'll ever need to deal with when persisting data on iOS.*

Disk follows Apple's [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html) and therefore allows you to store files in three primary directories:

#### Documents Directory `.documents`

"Only documents and other data that is **user-generated, or that cannot otherwise be recreated by your application**, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud."

#### Caches Directory `.caches`

"Data that **can be downloaded again or regenerated** should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.

Use this directory to write any application-specific support files that you want to persist between launches of the application or during application updates. **Your application is generally responsible for adding and removing these files** (see [Helper Methods](#helper-methods)). It should also be able to re-create these files as needed because iTunes removes them during a full restoration of the device. In iOS 2.2 and later, the contents of this directory are not backed up by iTunes.

Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed."

#### Temporary Directory `.temporary`

"Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device."


### Using Disk is easy.

### Structs (must conform to [Codable](https://developer.apple.com/documentation/swift/codable))

Let's say have a data model called `Message`...
```swift
struct Message: Codable {
    let title: String
    let body: String
}
```
... and we want to persist a message to disk...
```swift
let message = Message(title: "Hello", body: "How are you?")
Disk.store(message, to: .caches, as: "message")
```
... we might then want to retrieve this message from the caches directory...
```swift
let retrievedMessage = Disk.retrieve("message", from: .caches, as: Message.self)!
```

If you Option + click `retrievedMessage` then Xcode will show its type as `Message`. Pretty neat, huh?
<img src="https://user-images.githubusercontent.com/7799382/28501124-286520d8-6f8a-11e7-8ddb-53e956f8425a.png" alt="example">

So what happened in the background? Disk first converts `message` to JSON data and stores it as .json file to the caches directory. Then when we retrieve the `message`, Disk automatically converts the JSON data to our `Codable` struct type.

**What about arrays of structs?**

Thanks to the power of `Codable`, storing and retrieving arrays of structs is just as easy the code above.
```swift
var messages = [Message]()
for i in 0..<5 {
    messages.append(Message(title: "\(i)", body: "..."))
}
```
```swift
Disk.store(messages, to: .caches, as: "many-messages")
```
```swift
let retrievedMessages = Disk.retrieve("many-messages", from: .caches, as: [Message].self)!
```

### Images

Disk automatically converts `UIImage`s to .png or .jpg files. 

```swift
let image = UIImage(named: "nature.png")
```
```swift
Disk.store(image, to: .documents, as: "nature")
```
```swift
let retrievedImage = Disk.retrieve("nature", from: .documents, as: UIImage.self)!
```

**Array of images**

Multiple images are saved to a single directory with the given name. Each image is then named 1.png, 2.png, 3.png, etc. 
```swift
var images = [UIImages]()
// ...
```
```swift
Disk.store(images, to: .documents, as: "album")
```
```swift
let retrievedImages = Disk.retrieve("album", from: .documents, as: [UIImage].self)!
```

### Data

If you're trying to save data like .mp4 video data for example, then Disk's methods for `Data` will help you work with the file system to persist large files.

```swift
let videoData = Data(contentsOf: videoURL, options: [])
```
```swift
Disk.store(videoData, to: .documents, as: "anime")
```
```swift
let retrievedData = Disk.retrieve("anime", from: .documents, as: Data.self)!
```
**Array of `Data`**
```swift
var data = [Data]()
// ...
```
```swift
Disk.store(data, to: .documents, as: "videos")
```
```swift
let retrievedVideos = Disk.retrieve("videos", from: .documents, as: [Data].self)!
```
### Helper Methods

* Clear an entire directory
```swift
Disk.clear(.caches)
```
* Remove a certain file from a directory
```swift
Disk.remove("videos", from: .documents)
```
* Check if file exists with specified name at a directory
```swift
if Disk.fileExists("videos", in: .documents) {
    // ...
}
```
* Mark a file with the `do not backup` attribute (this keeps the file on disk even in low storage situations, but prevents it from being backed up by iCloud or iTunes.)
```swift
Disk.doNotBackup("message", in: .caches)
```
All files saved to the user's home directory are backed up by default.
```swift
Disk.backup("message", in: .caches)
```
You should generally never use the `.doNotBackup(:in:)` and `.backup(:in:)` methods unless you're absolutely positive you want to persist data no matter what state the user's device is in.

## Debugging

Disk is *forgiving*, meaning that it will handle most rookie mistakes on its own. However if you make a mistake that Disk thinks is worth telling you, it will print `Disk Error: [details about why an operation failed]` to the console instead of crashing the project at runtime. This should help you better manage your data and change your persistence game plan. 

## Documentation
Option + click on any of Disk's methods for detailed documentation.
<img src="https://user-images.githubusercontent.com/7799382/28500816-231ab8c8-6f84-11e7-93cb-875fceeeac65.png" alt="documentation">

## License

Disk uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using Disk.

## Contribute

Disk is in its infancy, but v0.0.6 provides the barebones of the simplest way to persist data in iOS. Please feel free to send pull requests of any features you think would add to Disk and its philosophy.

## Questions?

Contact me by email <a href="mailto:hello@saoudmr.com">hello@saoudmr.com</a>, or by twitter <a href="https://twitter.com/sdrzn" target="_blank">@sdrzn</a>. Please create an <a href="https://github.com/saoudrizwan/Disk/issues">issue</a> if you come across a bug or would like a feature to be added.
