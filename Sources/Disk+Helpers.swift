//
//  Disk+Helpers.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Get a file system URL for a persisted object
    ///
    /// - Parameters:
    ///   - name: name given to object
    ///   - directory: directory the object is saved in
    /// - Returns: URL pointing to file/folder holding the persisted object(s)
    /// - Throws: Error if no file could be found or too many files were found
    static func getURL(for name: String, in directory: Directory) throws -> URL {
        do {
            return try getOneExistingFileURL(for: name, with: [.none, .json, .png, .jpg, .directory], in: directory)
        } catch {
            throw error
        }
    }
    
    /// Clear directory by removing all files
    ///
    /// - Parameter directory: directory to clear
    /// - Throws: Error if File Manager cannot remove a file
    static func clear(_ directory: Directory) throws {
        let url = createURL(for: nil, extension: nil, in: directory)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            throw error
        }
    }
    
    /// Remove persisted object from file system
    ///
    /// - Parameters:
    ///   - name: name given to object when stored
    ///   - directory: directory where persisted object is located
    /// - Throws: Error if object file could not be removed
    static func remove(_ name: String, from directory: Directory) throws {
        do {
            let url = try getOneExistingFileURL(for: name, with: [.none, .json, .png, .jpg, .directory], in: directory)
            try FileManager.default.removeItem(at: url)
        } catch {
            throw error
        }
    }
    
    /// Checks if a object exists in the file system
    ///
    /// - Parameters:
    ///   - name: name given to object when stored
    ///   - directory: directory where persisted object is located
    /// - Returns: Bool indicating whether object exists at specified directory with specified name
    static func fileExists(_ name: String, in directory: Directory) -> Bool {
        let existingFileUrls = getExistingFileURLs(for: name, with: [.none, .json, .png, .jpg, .directory], in: directory)
        return existingFileUrls.count > 0
    }
    
    /// Sets the 'do not backup' attribute of the file on disk to true. This ensures that the file holding the object data does not get deleted when the user's device has low storage, but prevents this file from being stored in any backups made of the device on iTunes or iCloud.
    /// This is only useful for excluding cache and other application support files which are not needed in a backup. Some operations commonly made to user documents will cause the 'do not backup' property to be reset to false and so this should not be used on user documents.
    /// Warning: You must ensure that you will purge and handle any files created with this attribute appropriately, as these files will persist on the user's disk even in low storage situtations. If you don't handle these files appropriately, then you aren't following Apple's file system guidlines and can face App Store rejection.
    /// Ideally, you should let iOS handle deletion of files in low storage situations, and you yourself handle missing files appropriately (i.e. retrieving an image from the web again if it does not exist on disk anymore.)
    ///
    /// - Parameters:
    ///   - name: name given to file when stored
    ///   - directory: directory where persisted file is located
    /// - Throws: Error if file could not set its isExcludedFromBackup property
    static func doNotBackup(_ name: String, in directory: Directory) throws {
        do {
            try setIsExcludedFromBackupAttribute(to: true, for: name, in: directory)
        } catch {
            throw error
        }
    }
    
    /// Sets the 'do not backup' attribute of the file on disk to false. This is the default behaviour so you don't have to use this function unless you already called doNotBackup(name:directory:) on a specific file.
    /// This default backing up behaviour allows anything in the .documents and .caches directories to be stored in backups made of the user's device (on iCloud or iTunes)
    ///
    /// - Parameters:
    ///   - name: name given to file when stored
    ///   - directory: directory where persisted file is located
    /// - Throws: Error if file could not set its isExcludedFromBackup property
    static func backup(_ name: String, in directory: Directory) throws {
        do {
            try setIsExcludedFromBackupAttribute(to: false, for: name, in: directory)
        } catch {
            throw error
        }
    }
    
    /// Move persisted object to a new directory
    ///
    /// - Parameters:
    ///   - name: name given to object when stored
    ///   - directory: directory the file was originally stored in
    ///   - newDirectory: new directory to store file in
    /// - Throws: Error if file could not be moved
    static func move(_ name: String, in directory: Directory, to newDirectory: Directory) throws {
        do {
            let currentUrl = try getOneExistingFileURL(for: name, with: [.none, .json, .png, .jpg, .directory], in: directory)
            let justDirectoryPath = createURL(for: nil, extension: nil, in: directory).path
            let filePath = currentUrl.path.replacingOccurrences(of: justDirectoryPath, with: "")
            let newUrl = createURL(for: filePath, extension: nil, in: newDirectory)
            try FileManager.default.moveItem(at: currentUrl, to: newUrl)
        } catch {
            throw error
        }
    }
    
    /// Rename a persisted object in the file system
    ///
    /// - Parameters:
    ///   - name: original name given to persisted object
    ///   - directory: directory the object is persisted in
    ///   - newName: new name to give to persisted object
    /// - Throws: Error if object could not be renamed
    static func rename(_ name: String, in directory: Directory, to newName: String) throws {
        do {
            let currentUrl = try getOneExistingFileURL(for: name, with: [.none, .json, .png, .jpg, .directory], in: directory)
            let justDirectoryPath = createURL(for: nil, extension: nil, in: directory).path
            let currentFilePath = currentUrl.path.replacingOccurrences(of: justDirectoryPath, with: "")
            let currentValidFileName = stripInvalidCharactersForFileName(name)
            let newValidFileName = stripInvalidCharactersForFileName(newName)
            let newFilePath = currentFilePath.replacingOccurrences(of: currentValidFileName, with: newValidFileName)
            let newUrl = createURL(for: newFilePath, extension: nil, in: directory)
            try FileManager.default.moveItem(at: currentUrl, to: newUrl)
        } catch {
            throw error
        }
    }
}
