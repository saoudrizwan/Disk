//
//  Disk.swift
//  Disk
//
//  Created by Saoud Rizwan http://saoudmr.com
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

/**
 💾 Disk v0.0.8
 Easily work with the file system without worrying about any of its intricacies!
 
 - Store Codable structs, UIImage, [UIImage], Data, [Data] to Apple recommended locations on the user's disk
 - Retrieve an object from disk as the type you specify, without having to worry about conversion or casting
 - Remove specific objects from disk, clear entire directories if you need to, or check if an object exists on disk
 
 Data persistence has never been easier in Swift, and I hope Disk makes it evermore delightful!
 */
public class Disk {
    
    fileprivate init() { }
    
    // MARK: Directory URLs
    
    public enum Directory: String {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents = "Documents Directory"
        
        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        // Use this directory to write any application-specific support files that you want to persist between launches of the application or during application updates. Your application is generally responsible for adding and removing these files. It should also be able to re-create these files as needed because iTunes removes them during a full restoration of the device. In iOS 2.2 and later, the contents of this directory are not backed up by iTunes.
        // Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed.
        case caches = "Caches Directory"
        
        // Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device.
        case temporary = "Temporary Directory"
    }
    
    // MARK: Class helper methods
    
    enum FileExtension: String {
        case none = ""
        case json = ".json"
        case png = ".png"
        case jpg = ".jpg"
        case directory = "/"
    }
    
    /// Creates and returns a URL constructed from a specified directory + path
    static func createURL(for directory: Directory, name: String?, extension ext: FileExtension?) -> URL {
        var path: String? = nil
        if let name = name {
            path = name
        }
        if let ext = ext, name != nil {
            path = path! + ext.rawValue
        }
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        case .temporary:
            var temporaryUrl = FileManager.default.temporaryDirectory
            if let path = path {
                temporaryUrl = temporaryUrl.appendingPathComponent(path, isDirectory: false)
            }
            return temporaryUrl
        }
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            if let path = path {
                url = url.appendingPathComponent(path, isDirectory: false)
            }
            return url
        } else {
            fatalError("Could not create URL for specified directory")
        }
    }
    
    /// Iterates through file system to find a URL for a file/folder that exists with a specified name in directory with possible file extensions
    static func getExistingFileURL(for name: String, with possibleExtensions: [FileExtension], in directory: Directory) -> URL? {
        var possibleUrls = [URL]()
        let dataUrl = createURL(for: directory, name: name, extension: .none)
        let jsonUrl = createURL(for: directory, name: name, extension: .json)
        let pngUrl = createURL(for: directory, name: name, extension: .png)
        let jpgUrl = createURL(for: directory, name: name, extension: .jpg)
        let directoryUrl = createURL(for: directory, name: name, extension: .directory)
        for ext in possibleExtensions {
            switch ext {
            case .none:
                possibleUrls.append(dataUrl)
            case .json:
                possibleUrls.append(jsonUrl)
            case .png:
                possibleUrls.append(pngUrl)
            case .jpg:
                possibleUrls.append(jpgUrl)
            case .directory:
                possibleUrls.append(directoryUrl)
            }
        }
        var existingFileUrl: URL? = nil
        for url in possibleUrls {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    if possibleExtensions.contains(.directory) {
                        existingFileUrl = url
                    }
                } else {
                    existingFileUrl = url
                }
            }
        }
        return existingFileUrl
    }
    
    /// Print a Disk Error whenever a method fails
    static func printError(_ description: String) {
        print("❗️💾Disk: \(description)")
    }
    
    
    /// Set isExcludedFromBackup property of a file in the file system
    static func setIsExcludedFromBackupAttribute(to isExcludedFromBackup: Bool, for name: String, in directory: Directory) {
        let fileName = validateFileName(name)
        if let url = getExistingFileURL(for: fileName, with: [.none, .json, .png, .jpg], in: directory) {
            setIsExcludedFromBackupAttribute(to: isExcludedFromBackup, for: url)
        } else if let directoryUrl = getExistingFileURL(for: fileName, with: [.directory], in: directory) {
            do {
                let fileUrls = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: [])
                for fileUrl in fileUrls {
                    setIsExcludedFromBackupAttribute(to: isExcludedFromBackup, for: fileUrl)
                }
            } catch {
                printError(error.localizedDescription)
            }
        } else {
            printError("\(name) does not exist in \(directory.rawValue)")
        }
    }
    
    // Helper method for setIsExcludedFromBackupAttribute(to:for:in:)
    static func setIsExcludedFromBackupAttribute(to isExcludedFromBackup: Bool, for fileUrl: URL) {
        var url = fileUrl
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = isExcludedFromBackup
            try url.setResourceValues(resourceValues)
        } catch {
            printError(error.localizedDescription)
        }
    }
    
    /// Convert a user generated name to a valid file name (i.e. "Cool:Folder/images/png" -> "CoolFolderimagespng"
    static func validateFileName(_ unvalidatedName: String) -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":/")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        let validFileName = unvalidatedName
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
        guard validFileName.characters.count > 0  && validFileName != "." else {
            fatalError("\(unvalidatedName) is an invalid name. Choose another name with alphanumeric characters.")
        }
        return validFileName
    }
    
}
