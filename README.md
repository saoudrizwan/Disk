<p align="center">
    <img src="https://user-images.githubusercontent.com/7799382/29153673-a8eef618-7d43-11e7-850a-29897254f3d4.png" alt="Disk" />
</p>

<p align="center">
    <img src="https://user-images.githubusercontent.com/7799382/28644637-2fe6f818-720f-11e7-89a4-35250b6665ce.png" alt="Platform: iOS 9.0+" />
    <a href="https://developer.apple.com/swift" target="_blank"><img src="https://user-images.githubusercontent.com/7799382/28500845-b43a66fa-6f84-11e7-8281-6e689d8aaab9.png" alt="Language: Swift 4" /></a>
    <a href="https://cocoapods.org/pods/Disk" target="_blank"><img src="https://user-images.githubusercontent.com/7799382/29480095-d265263c-842a-11e7-9745-e4f2efcdc836.png" alt="CocoaPods compatible" /></a>
    <a href="https://github.com/Carthage/Carthage" target="_blank"><img src="https://user-images.githubusercontent.com/7799382/29480484-75d0ead4-842d-11e7-8c20-e42d6ae3554f.png" alt="Carthage compatible" /></a>
    <img src="https://user-images.githubusercontent.com/7799382/28500847-b6393648-6f84-11e7-9a7a-f6ae78207416.png" alt="License: MIT" />
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#debugging">Debugging</a>
  • <a href="#a-word-from-the-developer">A Word</a>
  • <a href="#license">License</a>
  • <a href="#contribute">Contribute</a>
</p>

Disk is a **powerful** and **simple** file management library built with Apple's [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html) in mind. Disk uses the new `Codable` protocol introduced in Swift 4 to its utmost advantage and gives you the power to persist JSON data without ever having to worry about encoding/decoding. Disk also helps you save images and other data types to disk with as little as one line of code.

## Compatibility

Disk requires **iOS 9+** and is compatible with **Swift 4** projects. Therefore you must use Xcode 9 when working with Disk.

## Installation

* Installation for <a href="https://guides.cocoapods.org/using/using-cocoapods.html" target="_blank">CocoaPods</a>:

```ruby
platform :ios, '9.0'
target 'ProjectName' do
use_frameworks!

    pod 'Disk', '~> 0.1.4'

end
```

* Installation for <a href="https://github.com/Carthage/Carthage" target="_blank">Carthage</a>:

 ```ruby
 github "saoudrizwan/Disk"
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

Disk follows Apple's [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html) and therefore allows you to save files in three primary directories:

#### Documents Directory `.documents`

"Only documents and other data that is **user-generated, or that cannot otherwise be recreated by your application**, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud."

#### Caches Directory `.caches`

"Data that **can be downloaded again or regenerated** should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.

Use this directory to write any application-specific support files that you want to persist between launches of the application or during application updates. **Your application is generally responsible for adding and removing these files** (see [Helper Methods](#helper-methods)). It should also be able to re-create these files as needed because iTunes removes them during a full restoration of the device. In iOS 2.2 and later, the contents of this directory are not backed up by iTunes.

Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed."

#### Temporary Directory `.temporary`

"Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device."

With all these requirements, it can be hard working with the iOS file system appropriately, which is why Disk was born. Disk makes following these tedious rules simple and fun.  

### Using Disk is easy.

Disk handles errors by `throw`ing them. See [Handling Errors Using Do-Catch](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html).

### Structs (must conform to [Codable](https://developer.apple.com/documentation/swift/codable))

Let's say we have a data model called `Message`...
```swift
struct Message: Codable {
    let title: String
    let body: String
}
```
... and we want to persist a message to disk...
```swift
let message = Message(title: "Hello", body: "How are you?")
```
```swift
try Disk.save(message, to: .caches, as: "message.json")
```
... or maybe we want to save it in a folder...
```swift
try Disk.save(message, to: .caches, as: "Folder/message.json")
```
... we might then want to retrieve this message later...
```swift
let retrievedMessage = try Disk.retrieve("Folder/message.json", from: .caches, as: Message.self)
```
If you Alt + click `retrievedMessage`, then Xcode will show its type as `Message`. Pretty neat, huh?
<img src="https://user-images.githubusercontent.com/7799382/28643842-0ab38230-720c-11e7-8bf4-33ce329068d1.png" alt="example">

So what happened in the background? Disk first converts `message` to JSON data and writes that data to a newly created file at `/Library/Caches/Folder/message.json`. Then when we retrieve the `message`, Disk automatically converts the JSON data to our `Codable` struct type.

**What about arrays of structs?**

Thanks to the power of `Codable`, storing and retrieving arrays of structs is just as easy as the code above.
```swift
var messages = [Message]()
for i in 0..<5 {
    messages.append(Message(title: "\(i)", body: "..."))
}
```
```swift
try Disk.save(messages, to: .caches, as: "many-messages.json")
```
```swift
let retrievedMessages = try Disk.retrieve("many-messages.json", from: .caches, as: [Message].self)
```

### Images
```swift
let image = UIImage(named: "nature.png")
```
```swift
try Disk.save(image, to: .documents, as: "Album/nature.png")
```
```swift
let retrievedImage = try Disk.retrieve("Album/nature.png", from: .documents, as: UIImage.self)
```

**Array of images**

Multiple images are saved to a new folder. Each image is then named 1.png, 2.png, 3.png, etc.
```swift
var images = [UIImages]()
// ...
```
```swift
try Disk.save(images, to: .documents, as: "FolderName/")
```
You don't need to include the "/" after the folder name, but doing so is declarative that you're not writing all the images' data to one file, but rather as several files to a new folder.
```swift
let retrievedImages = try Disk.retrieve("FolderName", from: .documents, as: [UIImage].self)
```
Let's say you saved a bunch of images to a folder like so:
```swift
try Disk.save(deer, to: .documents, as: "Nature/deer.png")
try Disk.save(lion, to: .documents, as: "Nature/lion.png")
try Disk.save(bird, to: .documents, as: "Nature/bird.png")
```
And maybe you even saved a JSON file to this Nature folder:
```swift
try Disk.save(diary, to: .documents, as: "Nature/diary.json")
```
Then you could retrieve all the images in the Nature folder like so:
```swift
let images = try Disk.retrieve("Nature", from: .documents, as: [UIImage].self)
```
... which would return `-> [deer.png, lion.png, bird.png]`

### Data

If you're trying to save data like .mp4 video data for example, then Disk's methods for `Data` will help you work with the file system to persist all data types.

```swift
let videoData = Data(contentsOf: videoURL, options: [])
```
```swift
try Disk.save(videoData, to: .documents, as: "anime.mp4")
```
```swift
let retrievedData = try Disk.retrieve("anime.mp4", from: .documents, as: Data.self)
```
**Array of `Data`**

Disk saves arrays of `Data` objects like it does arrays of images, as files in a folder.
```swift
var data = [Data]()
// ...
```
```swift
try Disk.save(data, to: .documents, as: "videos")
```
```swift
let retrievedVideos = try Disk.retrieve("videos", from: .documents, as: [Data].self)
```
If you were to retrieve `[Data]` from a folder with images and .json files, then those files would be included in the returned value. Continuing the example from the [Array of images](#images) section:
```swift
let files = try Disk.retrieve("Nature", from: .documents, as: [Data].self)
```
... would return `-> [deer.png, lion.png, bird.png, diary.json]`

### Large files
It's important to know when to work with the file system on the background thread. Disk is **synchronous**, giving you more control over read/write operations on the file system. [Apple says](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/TechniquesforReadingandWritingCustomFiles/TechniquesforReadingandWritingCustomFiles.html) that *"because file operations involve accessing the disk, performing those operations **asynchronously** is almost always preferred."*

[Grand Central Dispatch](https://developer.apple.com/documentation/dispatch) is the best way to work with Disk asynchronously. Here's an example:
```swift
activityIndicator.startAnimating()
DispatchQueue.global(qos: .background).async {
    do {
        try Disk.save(largeData, to: .documents, as: "Movies/spiderman.mp4")
    } catch {
        // ...
    }
    DispatchQueue.main.async {
        activityIndicator.stopAnimating()
        // ...
    }
}
```
*Don't forget to handle these sorts of tasks [being interrupted](https://stackoverflow.com/a/18305715/3502608).*

### Helper Methods

* Clear an entire directory
```swift
try Disk.clear(.caches)
```
* Remove a file/folder
```swift
try Disk.remove("video.mp4", from: .documents)
```
* Check if file/folder exists
```swift
if Disk.exists("album", in: .documents) {
    // ...
}
```
* Move a file/folder to another directory
```swift
try Disk.move("album/", in: .documents, to: .caches)
```
* Rename a file/folder
```swift
try Disk.rename("currentName.json", in: .documents, to: "newName.json")
```
* Get URL for an existing file/folder
```swift
try Disk.getURL(for: "album/", in: .documents)
```
* Mark a file/folder with the `do not backup` attribute (this keeps the file/folder on disk even in low storage situations, but prevents it from being backed up by iCloud or iTunes.)
```swift
try Disk.doNotBackup("album", in: .documents)
```
"Everything in your app’s home directory is backed up, **with the exception of the application bundle itself, the caches directory, and temporary directory.**"
```swift
try Disk.backup("album", in: .documents)
```
You should generally never use the `.doNotBackup(:in:)` and `.backup(:in:)` methods unless you're absolutely positive you want to persist data no matter what state the user's device is in.

## Debugging

Disk is *thorough*, meaning that it will not leave an error to chance. Almost all of Disk's methods throw errors either on behalf of `Foundation`'s `FileManager` class or custom Disk Errors that are worth bringing to your attention. These errors have a lot of information, such as a description, failure reason, and recovery suggestion:
```swift
do {
    if Disk.exists("posts.json", in: .documents) {
        try Disk.remove("posts.json", from: .documents)
    }
    try Disk.save(self.posts, to: .documents, as: "posts.json")
} catch let error as NSError {
    fatalError("""
        Domain: \(error.domain)
        Code: \(error.code)
        Description: \(error.localizedDescription)
        Failure Reason: \(error.localizedFailureReason ?? "")
        Suggestions: \(error.localizedRecoverySuggestion ?? "")
        """)
}
```
The example above takes care of the most common error when dealing with the file system: creating a file where one already exists with the same name. In the code above, we first check if posts.json exists, remove it if it does, and then write the new data to the new file.

## A Word from the Developer

After developing for iOS for 7+ years, I've come across almost every method of data persistence there is to offer (Core Data, Realm, `NSCoding`, `UserDefaults`, etc.) Nothing really fit the bill except `NSCoding`, but there were too many hoops to jump through. After Swift 4 was released, I was really excited about the `Codable` protocol because I knew what it had to offer in terms of JSON coding. Working with network responses' JSON data and converting them to usable structures has never been easier. **Disk aims to extend that simplicity of working with data to the file system.**

Let's say we get some data back from a network request...
```swift
let _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
    DispatchQueue.main.async {
        guard error == nil else { fatalError(error!.localizedDescription) }
        guard let data = data else { fatalError("No data retrieved") }

        // ... we could directly save this data to disk...
        try? Disk.save(data, to: .caches, as: "posts.json")

    }
}.resume()
```
```swift
// ... and retrieve it later as [Post]...
let posts = try Disk.retrieve("posts.json", from: .caches, as: [Post].self)
```

Disk takes out a lot of the tedious handy work required in coding data to the desired type, and it does it well. Disk also makes necessary but grueling tasks simple, such as clearing out the caches or temporary directory (as required by Apple's [iOS Data Storage Guidelines](https://developer.apple.com/icloud/documentation/data-storage/index.html)):

```swift
try! Disk.clear(.temporary)
```

Best of all, Disk is thorough when it comes to throwing errors, ensuring that you understand why a problem occurs when it does.

## Documentation
Option + click on any of Disk's methods for detailed documentation.
<img src="https://user-images.githubusercontent.com/7799382/29153708-e49f0842-7d43-11e7-8eb3-4b2d13b56b70.png" alt="documentation">

## License

Disk uses the MIT license. Please file an issue if you have any questions or if you'd like to share how you're using Disk.

## Contribute

Disk is in its infancy, but v0.1.4 provides the barebones of the simplest way to persist data in iOS. Please feel free to send pull requests of any features you think would add to Disk and its philosophy.

## Questions?

Contact me by email <a href="mailto:hello@saoudmr.com">hello@saoudmr.com</a>, or by twitter <a href="https://twitter.com/sdrzn" target="_blank">@sdrzn</a>. Please create an <a href="https://github.com/saoudrizwan/Disk/issues">issue</a> if you come across a bug or would like a feature to be added.
