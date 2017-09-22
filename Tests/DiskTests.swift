//
//  DiskTests.swift
//  DiskTests
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import XCTest
import Disk

class DiskTests: XCTestCase {
    
    // MARK: Helpers
    
    // Convert Error -> String of descriptions
    func convertErrorToString(_ error: Error) -> String {
        return """
        Domain: \((error as NSError).domain)
        Code: \((error as NSError).code)
        Description: \(error.localizedDescription)
        Failure Reason: \((error as NSError).localizedFailureReason ?? "nil")
        Suggestions: \((error as NSError).localizedRecoverySuggestion ?? "nil")\n
        """
    }
    
    // We'll clear out all our directories after each test
    override func tearDown() {
        do {
            try Disk.clear(.documents)
            try Disk.clear(.caches)
            try Disk.clear(.applicationSupport)
            try Disk.clear(.temporary)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    // MARK: Dummmy data
    
    let messages: [Message] = {
        var array = [Message]()
        for i in 1...10 {
            let element = Message(title: "Message \(i)", body: "...")
            array.append(element)
        }
        return array
    }()
    
    let images = [
        UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!,
        UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!,
        UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
    ]
    
    lazy var data: [Data] = self.images.map { UIImagePNGRepresentation($0)! }
    
    // MARK: Tests
    
    func testSaveStructs() {
        do {
            // 1 struct
            try Disk.save(messages[0], to: .documents, as: "message.json")
            XCTAssert(Disk.exists("message.json", in: .documents))
            let messageUrl = try Disk.getURL(for: "message.json", in: .documents)
            print("A message was saved as \(messageUrl.absoluteString)")
            let retrievedMessage = try Disk.retrieve("message.json", from: .documents, as: Message.self)
            XCTAssert(messages[0] == retrievedMessage)
            
            // ... in folder hierarchy
            try Disk.save(messages[0], to: .documents, as: "Messages/Bob/message.json")
            XCTAssert(Disk.exists("Messages/Bob/message.json", in: .documents))
            let messageInFolderUrl = try Disk.getURL(for: "Messages/Bob/message.json", in: .documents)
            print("A message was saved as \(messageInFolderUrl.absoluteString)")
            let retrievedMessageInFolder = try Disk.retrieve("Messages/Bob/message.json", from: .documents, as: Message.self)
            XCTAssert(messages[0] == retrievedMessageInFolder)
            
            // Array of structs
            try Disk.save(messages, to: .documents, as: "messages.json")
            XCTAssert(Disk.exists("messages.json", in: .documents))
            let messagesUrl = try Disk.getURL(for: "messages.json", in: .documents)
            print("Messages were saved as \(messagesUrl.absoluteString)")
            let retrievedMessages = try Disk.retrieve("messages.json", from: .documents, as: [Message].self)
            XCTAssert(messages == retrievedMessages)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testAppendStructs() {
        do {
            // Append a single struct to an empty location
            try Disk.append(messages[0], to: "single-message.json", in: .documents)
            let retrievedSingleMessage = try Disk.retrieve("single-message.json", from: .documents, as: [Message].self)
            XCTAssert(Disk.exists("single-message.json", in: .documents))
            XCTAssert(retrievedSingleMessage[0] == messages[0])
            
            // Append an array of structs to an empty location
            try Disk.append(messages, to: "multiple-messages.json", in: .documents)
            let retrievedMultipleMessages = try Disk.retrieve("multiple-messages.json", from: .documents, as: [Message].self)
            XCTAssert(Disk.exists("multiple-messages.json", in: .documents))
            XCTAssert(retrievedMultipleMessages == messages)
            
            // Append a single struct to a single struct
            try Disk.save(messages[0], to: .documents, as: "messages.json")
            XCTAssert(Disk.exists("messages.json", in: .documents))
            try Disk.append(messages[1], to: "messages.json", in: .documents)
            let retrievedMessages = try Disk.retrieve("messages.json", from: .documents, as: [Message].self)
            XCTAssert(retrievedMessages[0] == messages[0] && retrievedMessages[1] == messages[1])
            
            // Append an array of structs to a single struct
            try Disk.save(messages[5], to: .caches, as: "one-message.json")
            try Disk.append(messages, to: "one-message.json", in: .caches)
            let retrievedOneMessage = try Disk.retrieve("one-message.json", from: .caches, as: [Message].self)
            XCTAssert(retrievedOneMessage.count == messages.count + 1)
            XCTAssert(retrievedOneMessage[0] == messages[5])
            XCTAssert(retrievedOneMessage.last! == messages.last!)
            
            // Append a single struct to an array of structs
            try Disk.save(messages, to: .documents, as: "many-messages.json")
            try Disk.append(messages[1], to: "many-messages.json", in: .documents)
            let retrievedManyMessages = try Disk.retrieve("many-messages.json", from: .documents, as: [Message].self)
            XCTAssert(retrievedManyMessages.count == messages.count + 1)
            XCTAssert(retrievedManyMessages[0] == messages[0])
            XCTAssert(retrievedManyMessages.last! == messages[1])
            
            let array = [messages[0], messages[1], messages[2]]
            try Disk.save(array, to: .documents, as: "a-few-messages.json")
            XCTAssert(Disk.exists("a-few-messages.json", in: .documents))
            try Disk.append(messages[3], to: "a-few-messages.json", in: .documents)
            let retrievedFewMessages = try Disk.retrieve("a-few-messages.json", from: .documents, as: [Message].self)
            XCTAssert(retrievedFewMessages[0] == array[0] && retrievedFewMessages[1] == array[1] && retrievedFewMessages[2] == array[2] && retrievedFewMessages[3] == messages[3])
            
            // Append an array of structs to an array of structs
            try Disk.save(messages, to: .documents, as: "array-of-structs.json")
            try Disk.append(messages, to: "array-of-structs.json", in: .documents)
            let retrievedArrayOfStructs = try Disk.retrieve("array-of-structs.json", from: .documents, as: [Message].self)
            XCTAssert(retrievedArrayOfStructs.count == (messages.count * 2))
            XCTAssert(retrievedArrayOfStructs[0] == messages[0] && retrievedArrayOfStructs.last! == messages.last!)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testSaveImages() {
        do {
            // 1 image
            try Disk.save(images[0], to: .documents, as: "image.png")
            XCTAssert(Disk.exists("image.png", in: .documents))
            let imageUrl = try Disk.getURL(for: "image.png", in: .documents)
            print("An image was saved as \(imageUrl.absoluteString)")
            let retrievedImage = try Disk.retrieve("image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImage))
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .documents, as: "Photos/image.png")
            XCTAssert(Disk.exists("Photos/image.png", in: .documents))
            let imageInFolderUrl = try Disk.getURL(for: "Photos/image.png", in: .documents)
            print("An image was saved as \(imageInFolderUrl.absoluteString)")
            let retrievedInFolderImage = try Disk.retrieve("Photos/image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedInFolderImage))
            
            // Array of images
            try Disk.save(images, to: .documents, as: "album/")
            XCTAssert(Disk.exists("album/", in: .documents))
            let imagesFolderUrl = try Disk.getURL(for: "album/", in: .documents)
            print("Images were saved as \(imagesFolderUrl.absoluteString)")
            let retrievedImages = try Disk.retrieve("album/", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedImages[i]))
            }
            
            // ... in folder hierarchy
            try Disk.save(images, to: .documents, as: "Photos/summer-album/")
            XCTAssert(Disk.exists("Photos/summer-album/", in: .documents))
            let imagesInFolderUrl = try Disk.getURL(for: "Photos/summer-album/", in: .documents)
            print("Images were saved as \(imagesInFolderUrl.absoluteString)")
            let retrievedInFolderImages = try Disk.retrieve("Photos/summer-album/", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedInFolderImages[i]))
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testAppendImages() {
        do {
            // Append a single image to an empty folder
            try Disk.append(images[0], to: "EmptyFolder/", in: .documents)
            XCTAssert(Disk.exists("EmptyFolder/0.png", in: .documents))
            let retrievedImage = try Disk.retrieve("EmptyFolder", from: .documents, as: [UIImage].self)
            XCTAssert(Disk.exists("EmptyFolder/0.png", in: .documents))
            XCTAssert(retrievedImage.count == 1)
            XCTAssert(retrievedImage[0].dataEquals(images[0]))

            // Append an array of images to an empty folder
            try Disk.append(images, to: "EmptyFolder2/", in: .documents)
            XCTAssert(Disk.exists("EmptyFolder2/0.png", in: .documents))
            var retrievedImages = try Disk.retrieve("EmptyFolder2", from: .documents, as: [UIImage].self)
            XCTAssert(retrievedImages.count == images.count)
            for i in 0..<retrievedImages.count {
                let image = retrievedImages[i]
                XCTAssert(image.dataEquals(images[i]))
            }
            
            // Append a single image to an existing folder with images
            try Disk.save(images, to: .documents, as: "Folder/")
            XCTAssert(Disk.exists("Folder/", in: .documents))
            try Disk.append(images[1], to: "Folder/", in: .documents)
            retrievedImages = try Disk.retrieve("Folder/", from: .documents, as: [UIImage].self)
            XCTAssert(retrievedImages.count == images.count + 1)
            XCTAssert(Disk.exists("Folder/3.png", in: .documents))
            XCTAssert(retrievedImages.last!.dataEquals(images[1]))
            
            // Append an array of images to an existing folder with images
            try Disk.append(images, to: "Folder/", in: .documents)
            retrievedImages = try Disk.retrieve("Folder/", from: .documents, as: [UIImage].self)
            XCTAssert(retrievedImages.count == images.count * 2 + 1)
            XCTAssert(retrievedImages.last!.dataEquals(images.last!))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testSaveData() {
        do {
            // 1 data object
            try Disk.save(data[0], to: .documents, as: "file")
            XCTAssert(Disk.exists("file", in: .documents))
            let fileUrl = try Disk.getURL(for: "file", in: .documents)
            print("A file was saved to \(fileUrl.absoluteString)")
            let retrievedFile = try Disk.retrieve("file", from: .documents, as: Data.self)
            XCTAssert(data[0] == retrievedFile)
            
            // ... in folder hierarchy
            try Disk.save(data[0], to: .documents, as: "Folder/file")
            XCTAssert(Disk.exists("Folder/file", in: .documents))
            let fileInFolderUrl = try Disk.getURL(for: "Folder/file", in: .documents)
            print("A file was saved as \(fileInFolderUrl.absoluteString)")
            let retrievedInFolderFile = try Disk.retrieve("Folder/file", from: .documents, as: Data.self)
            XCTAssert(data[0] == retrievedInFolderFile)
            
            // Array of data
            try Disk.save(data, to: .documents, as: "several-files/")
            XCTAssert(Disk.exists("several-files/", in: .documents))
            let folderUrl = try Disk.getURL(for: "several-files/", in: .documents)
            print("Files were saved to \(folderUrl.absoluteString)")
            let retrievedFiles = try Disk.retrieve("several-files/", from: .documents, as: [Data].self)
            XCTAssert(data == retrievedFiles)
            
            // ... in folder hierarchy
            try Disk.save(data, to: .documents, as: "Folder/Files/")
            XCTAssert(Disk.exists("Folder/Files/", in: .documents))
            let filesInFolderUrl = try Disk.getURL(for: "Folder/Files/", in: .documents)
            print("Files were saved to \(filesInFolderUrl.absoluteString)")
            let retrievedInFolderFiles = try Disk.retrieve("Folder/Files/", from: .documents, as: [Data].self)
            XCTAssert(data == retrievedInFolderFiles)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testAppendData() {
        do {
            // Append a single data object to an empty folder
            try Disk.append(data[0], to: "EmptyFolder/", in: .documents)
            XCTAssert(Disk.exists("EmptyFolder/0", in: .documents))
            let retrievedObject = try Disk.retrieve("EmptyFolder", from: .documents, as: [Data].self)
            XCTAssert(Disk.exists("EmptyFolder/0", in: .documents))
            XCTAssert(retrievedObject.count == 1)
            XCTAssert(retrievedObject[0] == data[0])
            
            // Append an array of data objects to an empty folder
            try Disk.append(data, to: "EmptyFolder2/", in: .documents)
            XCTAssert(Disk.exists("EmptyFolder2/0", in: .documents))
            var retrievedObjects = try Disk.retrieve("EmptyFolder2", from: .documents, as: [Data].self)
            XCTAssert(retrievedObjects.count == data.count)
            for i in 0..<retrievedObjects.count {
                let object = retrievedObjects[i]
                XCTAssert(object == data[i])
            }
            
            // Append a single data object to an existing folder with files
            try Disk.save(data, to: .documents, as: "Folder/")
            XCTAssert(Disk.exists("Folder/", in: .documents))
            try Disk.append(data[1], to: "Folder/", in: .documents)
            retrievedObjects = try Disk.retrieve("Folder/", from: .documents, as: [Data].self)
            XCTAssert(retrievedObjects.count == data.count + 1)
            XCTAssert(retrievedObjects.last! == data[1])
            
            // Append an array of data objects to an existing folder with files
            try Disk.append(data, to: "Folder/", in: .documents)
            retrievedObjects = try Disk.retrieve("Folder/", from: .documents, as: [Data].self)
            XCTAssert(retrievedObjects.count == data.count * 2 + 1)
            XCTAssert(retrievedObjects.last! == data.last!)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testSaveAsDataRetrieveAsImage() {
        do {
            // save as data
            let image = images[0]
            let imageData = UIImagePNGRepresentation(image)!
            try Disk.save(imageData, to: .documents, as: "file")
            XCTAssert(Disk.exists("file", in: .documents))
            let fileUrl = try Disk.getURL(for: "file", in: .documents)
            print("A file was saved to \(fileUrl.absoluteString)")
            
            // Retrieve as image
            let retrievedFileAsImage = try Disk.retrieve("file", from: .documents, as: UIImage.self)
            XCTAssert(image.dataEquals(retrievedFileAsImage))
            
            // Array of data
            let arrayOfImagesData = images.map { UIImagePNGRepresentation($0)! } // -> [Data]
            try Disk.save(arrayOfImagesData, to: .documents, as: "data-folder/")
            XCTAssert(Disk.exists("data-folder/", in: .documents))
            let folderUrl = try Disk.getURL(for: "data-folder/", in: .documents)
            print("Files were saved to \(folderUrl.absoluteString)")
            // Retrieve the files as [UIImage]
            let retrievedFilesAsImages = try Disk.retrieve("data-folder/", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedFilesAsImages[i]))
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    
    }
    
    func testDocuments() {
        do {
            // json
            try Disk.save(messages, to: .documents, as: "messages.json")
            XCTAssert(Disk.exists("messages.json", in: .documents))
            
            // 1 image
            try Disk.save(images[0], to: .documents, as: "image.png")
            XCTAssert(Disk.exists("image.png", in: .documents))
            let retrievedImage = try Disk.retrieve("image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImage))
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .documents, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .documents))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImageInFolders))
            
            // Array of images
            try Disk.save(images, to: .documents, as: "album")
            XCTAssert(Disk.exists("album", in: .documents))
            let retrievedImages = try Disk.retrieve("album", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedImages[i]))
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testCaches() {
        do {
            // json
            try Disk.save(messages, to: .caches, as: "messages.json")
            XCTAssert(Disk.exists("messages.json", in: .caches))
            
            // 1 image
            try Disk.save(images[0], to: .caches, as: "image.png")
            XCTAssert(Disk.exists("image.png", in: .caches))
            let retrievedImage = try Disk.retrieve("image.png", from: .caches, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImage))
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .caches, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .caches))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .caches, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImageInFolders))
            
            // Array of images
            try Disk.save(images, to: .caches, as: "album")
            XCTAssert(Disk.exists("album", in: .caches))
            let retrievedImages = try Disk.retrieve("album", from: .caches, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedImages[i]))
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testApplicationSupport() {
        do {
            // json
            try Disk.save(messages, to: .applicationSupport, as: "messages.json")
            XCTAssert(Disk.exists("messages.json", in: .applicationSupport))
            
            // 1 image
            try Disk.save(images[0], to: .applicationSupport, as: "image.png")
            XCTAssert(Disk.exists("image.png", in: .applicationSupport))
            let retrievedImage = try Disk.retrieve("image.png", from: .applicationSupport, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImage))
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .applicationSupport, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .applicationSupport))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .applicationSupport))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .applicationSupport))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .applicationSupport))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .applicationSupport, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImageInFolders))
            
            // Array of images
            try Disk.save(images, to: .applicationSupport, as: "album")
            XCTAssert(Disk.exists("album", in: .applicationSupport))
            let retrievedImages = try Disk.retrieve("album", from: .applicationSupport, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedImages[i]))
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testTemporary() {
        do {
            // json
            try Disk.save(messages, to: .temporary, as: "messages.json")
            XCTAssert(Disk.exists("messages.json", in: .temporary))
            
            // 1 image
            try Disk.save(images[0], to: .temporary, as: "image.png")
            XCTAssert(Disk.exists("image.png", in: .temporary))
            let retrievedImage = try Disk.retrieve("image.png", from: .temporary, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImage))
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .temporary, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .temporary))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .temporary))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .temporary))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .temporary))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .temporary, as: UIImage.self)
            XCTAssert(images[0].dataEquals(retrievedImageInFolders))
            
            // Array of images
            try Disk.save(images, to: .temporary, as: "album")
            XCTAssert(Disk.exists("album", in: .temporary))
            let retrievedImages = try Disk.retrieve("album", from: .temporary, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].dataEquals(retrievedImages[i]))
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    // MARK: Test helper methods
    
    func testGetUrl() {
        do {
            try Disk.clear(.documents)
            // 1 struct
            try Disk.save(messages[0], to: .documents, as: "message.json")
            let messageUrlPath = try Disk.getURL(for: "message.json", in: .documents).path.replacingOccurrences(of: "file://", with: "")
            XCTAssert(FileManager.default.fileExists(atPath: messageUrlPath))
            
            // Array of images (folder)
            try Disk.save(images, to: .documents, as: "album")
            XCTAssert(Disk.exists("album", in: .documents))
            let folderUrlPath = try Disk.getURL(for: "album/", in: .documents).path.replacingOccurrences(of: "file://", with: "")
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: folderUrlPath, isDirectory: &isDirectory) {
                XCTAssert(isDirectory.boolValue)
            } else {
                XCTFail()
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testClear() {
        do {
            try Disk.save(messages[0], to: .caches, as: "message.json")
            XCTAssert(Disk.exists("message.json", in: .caches))
            try Disk.clear(.caches)
            XCTAssertFalse(Disk.exists("message.json", in: .caches))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testRemove() {
        do {
            try Disk.save(messages[0], to: .caches, as: "message.json")
            XCTAssert(Disk.exists("message.json", in: .caches))
            try Disk.remove("message.json", from: .caches)
            XCTAssertFalse(Disk.exists("message.json", in: .caches))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testExists() {
        do {
            try Disk.save(messages[0], to: .caches, as: "message.json")
            XCTAssert(Disk.exists("message.json", in: .caches))
            let messageUrl = try Disk.getURL(for: "message.json", in: .caches)
            XCTAssert(FileManager.default.fileExists(atPath: messageUrl.path))
            
            // folder
            try Disk.save(images, to: .documents, as: "album/")
            XCTAssert(Disk.exists("album/", in: .documents))
            XCTAssert(Disk.exists("album", in: .documents))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testDoNotBackupAndBackup() {
        do {
            // Do not backup
            try Disk.save(messages[0], to: .documents, as: "Messages/message.json")
            try Disk.doNotBackup("Messages/message.json", in: .documents)
            let messageUrl = try Disk.getURL(for: "Messages/message.json", in: .documents)
            if let resourceValues = try? messageUrl.resourceValues(forKeys: [.isExcludedFromBackupKey]),
                let isExcludedFromBackup = resourceValues.isExcludedFromBackup {
                XCTAssert(isExcludedFromBackup)
            } else {
                XCTFail()
            }
            
            // test on entire directory
            try Disk.save(images, to: .documents, as: "photos/")
            try Disk.doNotBackup("photos", in: .documents)
            let albumUrl = try Disk.getURL(for: "photos", in: .documents)
            if let resourceValues = try? albumUrl.resourceValues(forKeys: [.isExcludedFromBackupKey]),
                let isExcludedFromBackup = resourceValues.isExcludedFromBackup {
                XCTAssert(isExcludedFromBackup)
            } else {
                XCTFail()
            }
            
            // Backup
            try Disk.backup("Messages/message.json", in: .documents)
            let newMessageUrl = try Disk.getURL(for: "Messages/message.json", in: .documents) // we have to create a new url to access its new resource values
            if let resourceValues = try? newMessageUrl.resourceValues(forKeys: [.isExcludedFromBackupKey]),
                let isExcludedFromBackup = resourceValues.isExcludedFromBackup {
                XCTAssertFalse(isExcludedFromBackup)
            } else {
                XCTFail()
            }
            
            // test on entire directory
            try Disk.backup("photos/", in: .documents)
            let newAlbumUrl = try Disk.getURL(for: "photos/", in: .documents)
            if let resourceValues = try? newAlbumUrl.resourceValues(forKeys: [.isExcludedFromBackupKey]),
                let isExcludedFromBackup = resourceValues.isExcludedFromBackup {
                XCTAssertFalse(isExcludedFromBackup)
            } else {
                XCTFail()
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testMove() {
        do {
            try Disk.save(messages[0], to: .caches, as: "message.json")
            try Disk.move("message.json", in: .caches, to: .documents)
            XCTAssertFalse(Disk.exists("message.json", in: .caches))
            XCTAssert(Disk.exists("message.json", in: .documents))
            
            // Array of images in folder hierarchy
            try Disk.save(images, to: .caches, as: "album/")
            try Disk.move("album/", in: .caches, to: .documents)
            XCTAssertFalse(Disk.exists("album/", in: .caches))
            XCTAssert(Disk.exists("album/", in: .documents))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testRename() {
        do {
            try Disk.clear(.caches)
            try Disk.save(messages[0], to: .caches, as: "oldName.json")
            try Disk.rename("oldName.json", in: .caches, to: "newName.json")
            XCTAssertFalse(Disk.exists("oldName.json", in: .caches))
            XCTAssert(Disk.exists("newName.json", in: .caches))
            
            // Array of images in folder
            try Disk.save(images, to: .caches, as: "oldAlbumName/")
            try Disk.rename("oldAlbumName/", in: .caches, to: "newAlbumName/")
            XCTAssertFalse(Disk.exists("oldAlbumName/", in: .caches))
            XCTAssert(Disk.exists("newAlbumName/", in: .caches))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testWorkingWithFolderWithoutBackSlash() {
        do {
            try Disk.save(images, to: .caches, as: "album")
            try Disk.rename("album", in: .caches, to: "newAlbumName")
            XCTAssertFalse(Disk.exists("album", in: .caches))
            XCTAssert(Disk.exists("newAlbumName", in: .caches))
            
            try Disk.remove("newAlbumName", from: .caches)
            XCTAssertFalse(Disk.exists("newAlbumName", in: .caches))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testOverwrite() {
        do {
            let one = messages[1]
            let two = messages[2]
            try Disk.save(one, to: .caches, as: "message.json")
            try Disk.save(two, to: .caches, as: "message.json")
            // Array of images in folder
            let albumOne = [images[0], images[1]]
            let albumTwo = [images[1], images[2]]
            try Disk.save(albumOne, to: .caches, as: "album/")
            try Disk.save(albumTwo, to: .caches, as: "album/")
        } catch let error as NSError {
            // We want an NSCocoa error to be thrown when we try writing to the same file location again without first removing it first
            let alreadyExistsErrorCode = 516
            XCTAssert(error.code == alreadyExistsErrorCode)
        }
    }
    
    func testAutomaticSubFoldersCreation() {
        do {
            try Disk.save(messages, to: .caches, as: "Folder1/Folder2/Folder3/messages.json")
            XCTAssert(Disk.exists("Folder1", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3", in: .caches))
            XCTAssertFalse(Disk.exists("Folder2/Folder3/Folder1", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/messages.json", in: .caches))
            
            // Array of images in folder hierarchy
            try Disk.save(images, to: .documents, as: "Folder1/Folder2/Folder3/album")
            XCTAssert(Disk.exists("Folder1", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3", in: .documents))
            XCTAssertFalse(Disk.exists("Folder2/Folder3/Folder1", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/album", in: .documents))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testInvalidName() {
        do {
            try Disk.save(messages, to: .documents, as: "//////messages.json")
            XCTAssert(Disk.exists("messages.json", in: .documents))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testAddDifferentFileTypes() {
        do {
            try Disk.save(messages, to: .documents, as: "Folder/messages.json")
            XCTAssert(Disk.exists("Folder/messages.json", in: .documents))
            try Disk.save(images[0], to: .documents, as: "Folder/image1.png")
            XCTAssert(Disk.exists("Folder/image1.png", in: .documents))
            try Disk.save(images[1], to: .documents, as: "Folder/image2.jpg")
            XCTAssert(Disk.exists("Folder/image2.jpg", in: .documents))
            try Disk.save(images[2], to: .documents, as: "Folder/image3.jpeg")
            XCTAssert(Disk.exists("Folder/image3.jpeg", in: .documents))
            
            let files = try Disk.retrieve("Folder", from: .documents, as: [Data].self)
            XCTAssert(files.count == 4)
            
            let album = try Disk.retrieve("Folder", from: .documents, as: [UIImage].self)
            XCTAssert(album.count == 3)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    // Test sorting of many files saved to folder as array
    func testFilesRetrievalSorting() {
        do {
            let manyObjects = data + data + data + data + data
            try Disk.save(manyObjects, to: .documents, as: "Folder/")
            
            let retrievedFiles = try Disk.retrieve("Folder", from: .documents, as: [Data].self)
            
            for i in 0..<manyObjects.count {
                let object = manyObjects[i]
                let file = retrievedFiles[i]
                XCTAssert(object == file)
            }
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    // Test saving struct/structs as a folder
    func testExpectedErrorForSavingStructsAsFilesInAFolder() {
        do {
            let oneMessage = messages[0]
            let multipleMessages = messages
            
            try Disk.save(oneMessage, to: .documents, as: "Folder/")
            try Disk.save(multipleMessages, to: .documents, as: "Folder/")
            try Disk.append(oneMessage, to: "Folder/", in: .documents)
            let _ = try Disk.retrieve("Folder/", from: .documents, as: [Message].self)
        } catch let error as NSError {
            XCTAssert(error.code == Disk.ErrorCode.invalidFileName.rawValue)
        }
    }
    
    // Test iOS 11 Volume storage resource values
    @available(iOS 11.0, *)
    func testiOS11VolumeStorageResourceValues() {
        XCTAssert(Disk.totalCapacity != nil && Disk.totalCapacity != 0)
        XCTAssert(Disk.availableCapacity != nil && Disk.availableCapacity != 0)
        XCTAssert(Disk.availableCapacityForImportantUsage != nil && Disk.availableCapacityForImportantUsage != 0)
        XCTAssert(Disk.availableCapacityForOpportunisticUsage != nil && Disk.availableCapacityForOpportunisticUsage != 0)
        
        print("\n\n============== Disk iOS 11 Volume Information ==============")
        print("Disk.totalCapacity = \(Disk.totalCapacity!)")
        print("Disk.availableCapacity = \(Disk.availableCapacity!)")
        print("Disk.availableCapacityForImportantUsage = \(Disk.availableCapacityForImportantUsage!)")
        print("Disk.availableCapacityForOpportunisticUsage = \(Disk.availableCapacityForOpportunisticUsage!)")
        print("============================================================\n\n")
    }
}
