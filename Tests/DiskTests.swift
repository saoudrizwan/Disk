//
//  DiskTests.swift
//  DiskTests
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import XCTest
@testable import Disk

class DiskTests: XCTestCase {
    func convertErrorToString(_ error: Error) -> String {
        return """
        Domain: \((error as NSError).domain)
        Code: \((error as NSError).code)
        Description: \(error.localizedDescription)
        Failure Reason: \((error as NSError).localizedFailureReason ?? "nil")
        Suggestions: \((error as NSError).localizedRecoverySuggestion ?? "nil")
        """
    }
    
    override func tearDown() {
        do {
            try Disk.clear(.documents)
            try Disk.clear(.caches)
            try Disk.clear(.temporary)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    
    
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
    
    func testStoreStructs() {
        do {
            // 1 struct
            let message = messages[0]
            try Disk.store(message, to: .documents, as: "message")
            XCTAssert(Disk.fileExists("message", in: .documents))
            let messageUrl = try Disk.getURL(for: "message", in: .documents)
            print("A message was stored to \(messageUrl.absoluteString)")
            let retrievedMessage = try Disk.retrieve("message", from: .documents, as: Message.self)
            XCTAssert(message == retrievedMessage)
            
            // Array of structs
            try Disk.store(messages, to: .documents, as: "messages")
            XCTAssert(Disk.fileExists("messages", in: .documents))
            let messagesUrl = try Disk.getURL(for: "messages", in: .documents)
            print("Messages were stored to \(messagesUrl.absoluteString)")
            let retrievedMessages = try Disk.retrieve("messages", from: .documents, as: [Message].self)
            XCTAssert(messages == retrievedMessages)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testStoreImages() {
        do {
            // 1 image
            let image = images[0]
            try Disk.store(image, to: .documents, as: "image")
            XCTAssert(Disk.fileExists("image", in: .documents))
            let imageUrl = try Disk.getURL(for: "image", in: .documents)
            print("An image was stored to \(imageUrl.absoluteString)")
            let retrievedImage = try Disk.retrieve("image", from: .documents, as: UIImage.self)
            XCTAssert(image == retrievedImage)
            
            // Array of images
            try Disk.store(images, to: .documents, as: "images")
            XCTAssert(Disk.fileExists("images", in: .documents))
            let imagesFolderUrl = try Disk.getURL(for: "images", in: .documents)
            print("Images were stored to \(imagesFolderUrl.absoluteString)")
            let retrievedImages = try Disk.retrieve("images", from: .documents, as: [UIImage].self)
            XCTAssert(images == retrievedImages)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    func testStoreData() {
        do {
            // 1 data object
            let object = data[0]
            try Disk.store(object, to: .documents, as: "image")
            XCTAssert(Disk.fileExists("image", in: .documents))
            let imageUrl = try Disk.getURL(for: "image", in: .documents)
            print("An image was stored to \(imageUrl.absoluteString)")
            let retrievedImage = try Disk.retrieve("image", from: .documents, as: UIImage.self)
            XCTAssert(image == retrievedImage)
            
            // Array of images
            try Disk.store(images, to: .documents, as: "images")
            XCTAssert(Disk.fileExists("images", in: .documents))
            let imagesFolderUrl = try Disk.getURL(for: "images", in: .documents)
            print("Images were stored to \(imagesFolderUrl.absoluteString)")
            let retrievedImages = try Disk.retrieve("images", from: .documents, as: [UIImage].self)
            XCTAssert(images == retrievedImages)
        } catch {
            fatalError(convertErrorToString(error))
        }
    }
    
    
    func testStoreSingleData() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let data = UIImagePNGRepresentation(deku)!
        
        Disk.store(data, to: .documents, as: "my-data")
        
        if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent("my-data", isDirectory: false)
            XCTAssert(FileManager.default.fileExists(atPath: url.path))
        } else {
            XCTFail()
        }
    }
    
    func testRetrieveSingleData() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let data = UIImagePNGRepresentation(deku)!
        
        Disk.store(data, to: .documents, as: "my-data")
        
        guard let retrievedData = Disk.retrieve("my-data", from: .documents, as: Data.self) else {
            XCTFail()
            return
        }
        
        XCTAssert(data == retrievedData)
    }
    
    func testStoreMultipleData() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        
        let dekuData = UIImagePNGRepresentation(deku)!
        let allMightData = UIImagePNGRepresentation(allMight)!
        let bakugoData = UIImagePNGRepresentation(bakugo)!
        
        let data = [dekuData, allMightData, bakugoData]
        
        Disk.store(data, to: .documents, as: "my-data")
        
        // Test to see if we create a directory named "my-data" (this directory will hold all our files which will be named 1, 2, 3, etc.)
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = url.appendingPathComponent("my-data", isDirectory: true)
            
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                XCTAssert(isDirectory.boolValue)
            } else {
                XCTFail()
            }
        }
        
        // Test to see if the data stored in the directory is correct
        var retrievedData = [Data]()
        
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = url.appendingPathComponent("my-data", isDirectory: true)
            if FileManager.default.fileExists(atPath: url.path) {
                let files = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                XCTAssert(files.count == data.count)
                for fileUrl in files {
                    if let retrieved = FileManager.default.contents(atPath: fileUrl.path) {
                        retrievedData.append(retrieved)
                    }
                }
            } else {
                XCTFail()
            }
        }
        
        XCTAssert(retrievedData.count == data.count)
        
        for i in 0..<retrievedData.count {
            XCTAssert(retrievedData[i] == data[i])
        }
    }
    
    func testRetrieveMultipleData() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        
        let dekuData = UIImagePNGRepresentation(deku)!
        let allMightData = UIImagePNGRepresentation(allMight)!
        let bakugoData = UIImagePNGRepresentation(bakugo)!
        
        let data = [dekuData, allMightData, bakugoData]
        
        Disk.store(data, to: .documents, as: "my-data")
        
        guard let retrievedDataFromDisk = Disk.retrieve("my-data", from: .documents, as: [Data].self) else {
            XCTFail()
            return
        }
        
        // Test to see if the data stored in the directory is correct
        var retrievedDataFromFileManager = [Data]()
        
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = url.appendingPathComponent("my-data", isDirectory: true)
            if FileManager.default.fileExists(atPath: url.path) {
                let files = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                XCTAssert(files.count == data.count)
                for fileUrl in files {
                    if let retrieved = FileManager.default.contents(atPath: fileUrl.path) {
                        retrievedDataFromFileManager.append(retrieved)
                    }
                }
            } else {
                XCTFail()
            }
        }
        
        XCTAssert(retrievedDataFromDisk.count == retrievedDataFromFileManager.count)
        
        for i in 0..<retrievedDataFromFileManager.count {
            XCTAssert(retrievedDataFromFileManager[i] == retrievedDataFromDisk[i])
        }
    }
    
    func testTemporary() {
        let deku = UIImagePNGRepresentation(UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!)!
        Disk.store(deku, to: .temporary, as: "deku")
        let retrievedDeku = UIImagePNGRepresentation(Disk.retrieve("deku", from: .temporary, as: UIImage.self)!)!
        XCTAssert(deku == retrievedDeku)
        Disk.doNotBackup("deku", in: .temporary)
        Disk.remove("deku", from: .temporary)
        XCTAssertFalse(Disk.fileExists("deku", in: .temporary))
    }
    
    func testRenameObject() {
        let message = Message(title: "title", body: "body")
        Disk.store(message, to: .caches, as: "oldName")
        Disk.rename("oldName", in: .caches, to: "newName")
        XCTAssertFalse(Disk.fileExists("oldName", in: .caches))
        XCTAssert(Disk.fileExists("newName", in: .caches))
        guard let retrievedMessage = Disk.retrieve("newName", from: .caches, as: Message.self) else {
            XCTFail()
            return
        }
        XCTAssert(message.title == retrievedMessage.title && message.body == retrievedMessage.body)
    }
    
    func testMoveObject() {
        let message = Message(title: "title", body: "body")
        Disk.store(message, to: .caches, as: "message")
        Disk.move("message", in: .caches, to: .temporary)
        XCTAssertFalse(Disk.fileExists("message", in: .caches))
        XCTAssert(Disk.fileExists("message", in: .temporary))
        guard let retrievedMessage = Disk.retrieve("message", from: .temporary, as: Message.self) else {
            XCTFail()
            return
        }
        XCTAssert(message.title == retrievedMessage.title && message.body == retrievedMessage.body)
    }
    
    func testFolderHandling() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let images = [deku, allMight, bakugo]
        
        Disk.store(images, to: .documents, as: "heroes")
        
        // Rename
        Disk.rename("heroes", in: .documents, to: "villains")
        XCTAssertFalse(Disk.fileExists("heroes", in: .documents))
        XCTAssert(Disk.fileExists("villains", in: .documents))
        
        // Move
        Disk.move("villains", in: .documents, to: .caches)
        XCTAssertFalse(Disk.fileExists("villains", in: .documents))
        XCTAssert(Disk.fileExists("villains", in: .caches))
        
        // Do not backup
        Disk.doNotBackup("villains", in: .caches)
        
        // Retrieve
        guard let retrievedImages = Disk.retrieve("villains", from: .caches, as: [UIImage].self) else {
            XCTFail()
            return
        }
        XCTAssert(images.count == retrievedImages.count)
        
        // Remove
        Disk.remove("villains", from: .caches)
        XCTAssertFalse(Disk.fileExists("villains", in: .caches))
    }
    
    func testWeirdNames() {
        let weirdName = "user-messages/saoud*.adf3/jpeg.message.png/.json"
        let weirdName2 = ".adf/"
        
        let message = Message(title: "title", body: "body")
        Disk.store(message, to: .caches, as: weirdName)
        guard let retrievedMessage = Disk.retrieve(weirdName, from: .caches, as: Message.self) else {
            XCTFail()
            return
        }
        XCTAssert(message.title == retrievedMessage.title && message.body == retrievedMessage.body)
        Disk.remove(weirdName, from: .caches)
        
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let images = [deku, allMight, bakugo]
        Disk.store(images, to: .documents, as: weirdName)
        
        // Rename
        Disk.rename(weirdName, in: .documents, to: weirdName2)
        XCTAssertFalse(Disk.fileExists(weirdName, in: .documents))
        XCTAssert(Disk.fileExists(weirdName2, in: .documents))
        
        // Move
        Disk.move(weirdName2, in: .documents, to: .caches)
        XCTAssertFalse(Disk.fileExists(weirdName2, in: .documents))
        XCTAssert(Disk.fileExists(weirdName2, in: .caches))
        
        // Do not backup
        Disk.doNotBackup(weirdName2, in: .caches)
        
        // Retrieve
        guard let retrievedImages = Disk.retrieve(weirdName2, from: .caches, as: [UIImage].self) else {
            XCTFail()
            return
        }
        XCTAssert(images.count == retrievedImages.count)
        
        // Remove
        Disk.remove(weirdName2, from: .caches)
        XCTAssertFalse(Disk.fileExists("villains", in: .caches))
    }
    
    func testOverwrite() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        
        let heroes = [deku, allMight, bakugo]
        let kids = [deku, bakugo]
        
        Disk.store(heroes, to: .documents, as: "coolName")
        Disk.store(kids, to: .documents, as: "coolName")
        
        guard let retrievedImages = Disk.retrieve("coolName", from: .documents, as: [UIImage].self) else {
            XCTFail()
            return
        }
        XCTAssert(kids.count == retrievedImages.count)
    }
    
    func testDoNotBackup() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        Disk.store(deku, to: .caches, as: "deku")
        
        Disk.doNotBackup("deku", in: .caches)
        
        if let url = Disk.getURL(for: "deku", in: .caches),
            let resourceValues = try? url.resourceValues(forKeys: [.isExcludedFromBackupKey]),
            let isExcludedFromBackup = resourceValues.isExcludedFromBackup {
            XCTAssert(isExcludedFromBackup)
        } else {
            XCTFail()
        }
        
        Disk.backup("deku", in: .caches)
        
        if let url = Disk.getURL(for: "deku", in: .caches),
            let resourceValues = try? url.resourceValues(forKeys: [.isExcludedFromBackupKey]),
            let isExcludedFromBackup = resourceValues.isExcludedFromBackup {
            XCTAssertFalse(isExcludedFromBackup)
        } else {
            XCTFail()
        }
    }
    
    func testStoreSameName() {
        let one = Message(title: "one", body: "body")
        let two = Message(title: "two", body: "body")
        Disk.store(one, to: .caches, as: "message")
        Disk.store(two, to: .caches, as: "message")
        
        XCTAssert(Disk.fileExists("message", in: .caches))
        
        guard let retrievedMessage = Disk.retrieve("message", from: .caches, as: Message.self) else {
            XCTFail()
            return
        }
        XCTAssert(two.title == retrievedMessage.title && two.body == retrievedMessage.body)
        
    }
}
