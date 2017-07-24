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
    
    override func tearDown() {
        Disk.clear(.documents)
        Disk.clear(.caches)
        Disk.clear(.temporary)
    }
    
    func testPerformanceOfStoringALotOfMessages() {
        var messages = [Message]()
        
        for i in 1...1000 {
            let newMessage = Message(title: "Message \(i)", body: "...")
            messages.append(newMessage)
        }
        
        self.measure {
            Disk.store(messages, to: .documents, as: "a-lot-of-messages")
        }
    }
    
    func testStoreMessages() {
        var messages = [Message]()
        for i in 1...4 {
            let newMessage = Message(title: "Message \(i)", body: "...")
            messages.append(newMessage)
        }
        
        Disk.store(messages, to: .documents, as: "messages")
        
        if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent("messages.json", isDirectory: false)
            XCTAssert(FileManager.default.fileExists(atPath: url.path))
        } else {
            XCTFail()
        }
    }
    
    func testRetrieveMessages() {
        var messages = [Message]()
        for i in 1...4 {
            let newMessage = Message(title: "Message \(i)", body: "...")
            messages.append(newMessage)
        }
        Disk.store(messages, to: .documents, as: "messages")
        
        guard let retrievedMessages = Disk.retrieve("messages", from: .documents, as: [Message].self) else {
            XCTFail()
            return
        }
        let aMessageBody = retrievedMessages[0].body
        XCTAssert(aMessageBody == "...")
    }
    
    func testRemoveMessages() {
        var messages = [Message]()
        for i in 1...4 {
            let newMessage = Message(title: "Message \(i)", body: "...")
            messages.append(newMessage)
        }
        Disk.store(messages, to: .documents, as: "some-messages")
        XCTAssert(Disk.fileExists("some-messages", in: .documents))
        Disk.remove("some-messages", from: .documents)
        
        if var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            url = url.appendingPathComponent("some-messages.json", isDirectory: false)
            XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        } else {
            XCTFail()
        }
    }
    
    func testStoreImage() {
        let dekuImage = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        
        Disk.store(dekuImage, to: .documents, as: "my-image")
        
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pngUrl = url.appendingPathComponent("my-image.png", isDirectory: false)
            let jpgUrl = url.appendingPathComponent("my-image.jpg", isDirectory: false)
            XCTAssert(FileManager.default.fileExists(atPath: pngUrl.path) || FileManager.default.fileExists(atPath: jpgUrl.path))
        } else {
            XCTFail()
        }
        
    }
    
    func testStoreImages() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let images = [deku, allMight, bakugo]
        
        Disk.store(images, to: .documents, as: "my-images")
        
        // Test to see if we create a directory named "my-images" (this directory will hold all our images which will be named 1.png, 2.png, 3.png, etc.)
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = url.appendingPathComponent("my-images", isDirectory: true)
            
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                XCTAssert(isDirectory.boolValue)
            } else {
                XCTFail()
            }
        }
        
        // Test to see if we have png or jpg files in our new directory
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = url.appendingPathComponent("my-images", isDirectory: true)
            if FileManager.default.fileExists(atPath: url.path) {
                let files = try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                XCTAssert(files.count == images.count)
                for fileUrl in files {
                    let ext = fileUrl.pathExtension.lowercased()
                    print(ext)
                    XCTAssert(ext == "png" || ext == "jpg")
                }
            } else {
                XCTFail()
            }
        }
    }
    
    func testRetrieveImages() {
        let deku = UIImage(named: "Deku", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let allMight = UIImage(named: "AllMight", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let bakugo = UIImage(named: "Bakugo", in: Bundle(for: DiskTests.self), compatibleWith: nil)!
        let images = [deku, allMight, bakugo]
        
        Disk.store(images, to: .documents, as: "my-images")
        XCTAssert(Disk.fileExists("my-images", in: .documents))
        
        
        guard let retrievedImages = Disk.retrieve("my-images", from: .documents, as: [UIImage].self) else {
            XCTFail()
            return
        }
        
        XCTAssert(retrievedImages.count == images.count)
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
}
