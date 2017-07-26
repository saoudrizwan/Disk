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
    
    func testSaveImages() {
        do {
            // 1 image
            try Disk.save(images[0], to: .documents, as: "image.png")
            XCTAssert(Disk.exists("image.png", in: .documents))
            let imageUrl = try Disk.getURL(for: "image.png", in: .documents)
            print("An image was saved as \(imageUrl.absoluteString)")
            let retrievedImage = try Disk.retrieve("image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].size == retrievedImage.size)
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .documents, as: "Photos/image.png")
            XCTAssert(Disk.exists("Photos/image.png", in: .documents))
            let imageInFolderUrl = try Disk.getURL(for: "Photos/image.png", in: .documents)
            print("An image was saved as \(imageInFolderUrl.absoluteString)")
            let retrievedInFolderImage = try Disk.retrieve("Photos/image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].size == retrievedInFolderImage.size)
            
            // Array of images
            try Disk.save(images, to: .documents, as: "album/")
            XCTAssert(Disk.exists("album/", in: .documents))
            let imagesFolderUrl = try Disk.getURL(for: "album/", in: .documents)
            print("Images were saved as \(imagesFolderUrl.absoluteString)")
            let retrievedImages = try Disk.retrieve("album/", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].size == retrievedImages[i].size)
            }
            
            // ... in folder hierarchy
            try Disk.save(images, to: .documents, as: "Photos/summer-album/")
            XCTAssert(Disk.exists("Photos/summer-album/", in: .documents))
            let imagesInFolderUrl = try Disk.getURL(for: "Photos/summer-album/", in: .documents)
            print("Images were saved as \(imagesInFolderUrl.absoluteString)")
            let retrievedInFolderImages = try Disk.retrieve("Photos/summer-album/", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].size == retrievedInFolderImages[i].size)
            }
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
            XCTAssert(image.size == retrievedFileAsImage.size)
            
            // Array of data
            let arrayOfImagesData = images.map { UIImagePNGRepresentation($0)! } // -> [Data]
            try Disk.save(arrayOfImagesData, to: .documents, as: "data-folder/")
            XCTAssert(Disk.exists("data-folder/", in: .documents))
            let folderUrl = try Disk.getURL(for: "data-folder/", in: .documents)
            print("Files were saved to \(folderUrl.absoluteString)")
            // Retrieve the files as [UIImage]
            let retrievedFilesAsImages = try Disk.retrieve("data-folder/", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].size == retrievedFilesAsImages[i].size)
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
            XCTAssert(images[0].size == retrievedImage.size)
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .documents, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .documents))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .documents))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .documents, as: UIImage.self)
            XCTAssert(images[0].size == retrievedImageInFolders.size)
            
            // Array of images
            try Disk.save(images, to: .documents, as: "album")
            XCTAssert(Disk.exists("album", in: .documents))
            let retrievedImages = try Disk.retrieve("album", from: .documents, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].size == retrievedImages[i].size)
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
            XCTAssert(images[0].size == retrievedImage.size)
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .caches, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .caches))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .caches))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .caches, as: UIImage.self)
            XCTAssert(images[0].size == retrievedImageInFolders.size)
            
            // Array of images
            try Disk.save(images, to: .caches, as: "album")
            XCTAssert(Disk.exists("album", in: .caches))
            let retrievedImages = try Disk.retrieve("album", from: .caches, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].size == retrievedImages[i].size)
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
            XCTAssert(images[0].size == retrievedImage.size)
            
            // ... in folder hierarchy
            try Disk.save(images[0], to: .temporary, as: "Folder1/Folder2/Folder3/image.png")
            XCTAssert(Disk.exists("Folder1", in: .temporary))
            XCTAssert(Disk.exists("Folder1/Folder2/", in: .temporary))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/", in: .temporary))
            XCTAssert(Disk.exists("Folder1/Folder2/Folder3/image.png", in: .temporary))
            let retrievedImageInFolders = try Disk.retrieve("Folder1/Folder2/Folder3/image.png", from: .temporary, as: UIImage.self)
            XCTAssert(images[0].size == retrievedImageInFolders.size)
            
            // Array of images
            try Disk.save(images, to: .temporary, as: "album")
            XCTAssert(Disk.exists("album", in: .temporary))
            let retrievedImages = try Disk.retrieve("album", from: .temporary, as: [UIImage].self)
            for i in 0..<images.count {
                XCTAssert(images[i].size == retrievedImages[i].size)
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
            try Disk.save(messages, to: .documents, as: "//////messages.json/")
            XCTAssert(Disk.exists("messages.json", in: .documents))
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
}
