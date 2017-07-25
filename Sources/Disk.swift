//
//  Disk.swift
//  Disk
//
//  Created by Saoud Rizwan http://saoudmr.com
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

/**
 💾 Disk v0.1.0
 Easily work with the file system without worrying about any of its intricacies!
 
 - Store Codable structs, UIImage, [UIImage], Data, [Data] to Apple recommended locations on the user's disk, without having to worry about serialization.
 - Retrieve an object from disk as the type you specify, without having to worry about deserialization.
 - Remove specific objects from disk, clear entire directories if you need to, check if an object exists on disk, and much more!
 
 Data persistence has never been easier in Swift, and I hope Disk makes it evermore delightful!
 */
public class Disk {
    fileprivate init() { }
    
    public enum Directory: String {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents = "<Application_Home>/Documents"
        
        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        // Use this directory to write any application-specific support files that you want to persist between launches of the application or during application updates. Your application is generally responsible for adding and removing these files. It should also be able to re-create these files as needed because iTunes removes them during a full restoration of the device. In iOS 2.2 and later, the contents of this directory are not backed up by iTunes.
        // Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed.
        case caches = "<Application_Home>/Library/Caches"
        
        // Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device.
        case temporary = "<Application_Home>/tmp"
    }
}

// MARK: Internal helper methods

extension Disk {
    /// Creates and returns a URL constructed from specified directory/name.extension
    static func createURL(for path: String?, in directory: Directory) throws -> URL {
        var validPath: String? = nil
        if let path = path {
            do {
                validPath = try getValidFilePath(from: path)
            } catch {
                throw error
            }
        }
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        case .temporary:
            var temporaryUrl = URL(string: NSTemporaryDirectory())!
            if let validPath = validPath {
                temporaryUrl = temporaryUrl.appendingPathComponent(validPath, isDirectory: false)
            }
            return temporaryUrl
        }
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            if let validPath = validPath {
                url = url.appendingPathComponent(validPath, isDirectory: false)
            }
            return url
        } else {
            throw createError(
                .couldNotFindHomeDirectory,
                description: "Could not create URL for \(directory.rawValue)/\(validPath ?? "")",
                failureReason: "Could not get access to the file system's user domain mask.",
                recoverySuggestion: "Use a different directory."
            )
        }
    }
    
    /// Iterates through file system to find URLs for all existing files/folder
    static func getExistingFileURL(for path: String?, in directory: Directory) throws -> URL {
        do {
            var shouldBeFolder = true
            if let path = path {
                shouldBeFolder = path.hasSuffix("/")
            }
            let url = try createURL(for: path, in: directory)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if !(isDirectory.boolValue && !shouldBeFolder) {
                    return url
                }
            }
            throw createError(
                .noFileFound,
                description: "Could not find an existing \(shouldBeFolder ? "folder" : "file") at \(url.path).",
                failureReason: "There is no existing \(shouldBeFolder ? "folder" : "file") at \(url.path)",
                recoverySuggestion: "Check if a \(shouldBeFolder ? "folder" : "file") exists before trying to commit an operation on it."
            )
        } catch {
            throw error
        }
    }
    
    /// Throwing method that returns one and only one file URL for a specified name
//    static func getOneExistingFileURL(for name: String, with possibleExtensions: [FileExtension], in directory: Directory) throws -> URL {
//        do {
//            let existingFileUrls = try getExistingFileURLs(for: name, with: possibleExtensions, in: directory)
//            if existingFileUrls.count == 0 {
//                throw createError(
//                    .noFileFound,
//                    description: "No file with the name \"\(name)\" was found in \(directory.rawValue).",
//                    failureReason: "No file with the name \"\(name)\" was found in \(directory.rawValue).",
//                    recoverySuggestion: "Check if a file exists before trying to commit an operation on it."
//                )
//            } else if existingFileUrls.count != 1 {
//                throw createError(
//                    .tooManyFilesFound,
//                    description: "More than one file/folder with the name \"\(name)\" was found in \(directory.rawValue).",
//                    failureReason: "Re-store the file using Disk with an available file name.",
//                    recoverySuggestion: "Don't manually create a file or folder with the same name but different extension as a file or folder you previously created using Disk with the same name."
//                )
//            } else {
//                return existingFileUrls.first!
//            }
//        } catch {
//            throw error
//        }
//    }
    
    /// Convert a user generated name to a valid file name
    static func getValidFilePath(from originalString: String) throws -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        let validFileName = originalString
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
        guard validFileName.characters.count > 0  && validFileName != "." else {
            throw createError(
                .invalidFileName,
                description: "\(originalString) is an invalid file name.",
                failureReason: "Cannot write/read a file with the name \(originalString) on disk.",
                recoverySuggestion: "Use another file name with alphanumeric characters."
            )
        }
        return validFileName
    }
    
    /// Set 'isExcludedFromBackup' BOOL property of a file in the file system
    static func setIsExcludedFromBackupAttribute(to isExcludedFromBackup: Bool, for path: String?, in directory: Directory) throws {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            if isFolder(url) {
                let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                for fileUrl in fileUrls {
                    let subFolders = fileUrl.pathcom
                    try setIsExcludedFromBackupAttribute(to: isExcludedFromBackup, for: fileUrl)
                }
            } else {
                try setIsExcludedFromBackupAttribute(to: isExcludedFromBackup, for: url)
            }
        } catch {
            throw error
        }
    }
    
    /// Helper method for setIsExcludedFromBackupAttribute(to:for:in:)
    static func setIsExcludedFromBackupAttribute(to isExcludedFromBackup: Bool, for fileUrl: URL) throws {
        do {
            var url = fileUrl
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = isExcludedFromBackup
            try url.setResourceValues(resourceValues)
        } catch {
            throw error
        }
    }
    
    /// Check if file at a URL is a folder
    static func isFolder(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return true
            }
        }
        return false
    }
}
