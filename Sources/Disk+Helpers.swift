//
//  Disk+Helpers.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Get a file URL for a persisted object
    ///
    /// - Parameters:
    ///   - name: name given to object
    ///   - directory: directory the object is saved in
    /// - Returns: URL pointing to file/folder holding the persisted object(s)
    static func getURL(for name: String, in directory: Directory) -> URL? {
        let fileName = validateFileName(name)
        return getExistingFileURL(for: fileName, with: [.none, .json, .png, .jpg, .directory], in: directory)
    }
    
    /// Clear directory by removing all files
    ///
    /// - Parameter directory: directory to clear
    static func clear(_ directory: Directory) {
        let url = createURL(for: directory, name: nil, extension: nil)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            printError(error.localizedDescription)
        }
    }
    
    /// Remove file with name from specified directory
    ///
    /// - Parameters:
    ///   - name: file name given to file to remove (without extension)
    ///   - directory: directory where file to remove is located
    static func remove(_ name: String, from directory: Directory) {
        let fileName = validateFileName(name)
        if let url = getExistingFileURL(for: fileName, with: [.none, .json, .png, .jpg, .directory], in: directory) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                printError(error.localizedDescription)
            }
        } else {
            printError("\"\(name)\" does not exist in \(directory.rawValue)")
        }
    }
    
    /// Checks if file exists at specified directory with specified file name
    ///
    /// - Parameters:
    ///   - name: name of file (without extension)
    ///   - directory: directory where file is located
    /// - Returns: Bool indicating whether file exists at specified directory with specified file name
    static func fileExists(_ name: String, in directory: Directory) -> Bool {
        let fileName = validateFileName(name)
        if let _ = getExistingFileURL(for: fileName, with: [.none, .json, .png, .jpg, .directory], in: directory) {
            return true
        } else {
            return false
        }
    }
    
    /// Sets the 'do not backup' attribute of the object on disk to true. This ensures that the file holding the object data does not get deleted when the user's device has low storage, but prevents this file from being stored in any backups made of the device on iTunes or iCloud.
    /// This is only useful for excluding cache and other application support files which are not needed in a backup. Some operations commonly made to user documents will cause the 'do not backup' property to be reset to false and so this should not be used on user documents.
    /// Warning: You must ensure that you will purge and handle any files created with this attribute appropriately, as these files will persist on the user's disk even in low storage situtations. If you don't handle these files appropriately, then you aren't following Apple's file system guidlines and can face App Store rejection.
    /// Ideally, you should let iOS handle deletion of files in low storage situations, and you yourself handle missing files appropriately (i.e. retrieving an image from the web again if it does not exist on disk anymore.)
    ///
    /// - Parameters:
    ///   - name: name of object on disk
    ///   - directory: directory where object is stored
    static func doNotBackup(_ name: String, in directory: Directory) {
        setIsExcludedFromBackupAttribute(to: true, for: name, in: directory)
    }
    
    /// Sets the 'do not backup' attribute of the object on disk to false. This is the default behaviour so you don't have to use this function unless you already called doNotBackup(name:directory:) on a specific file.
    /// This default backing up behaviour allows anything in the .documents and .caches directories to be stored in backups made of the user's device (on iCloud or iTunes)
    ///
    /// - Parameters:
    ///   - name: name of object on disk
    ///   - directory: directory where object is stored
    static func backup(_ name: String, in directory: Directory) {
        setIsExcludedFromBackupAttribute(to: false, for: name, in: directory)
    }
    
    /// Move a persisted object to a new directory
    ///
    /// - Parameters:
    ///   - name: name given to persisted object
    ///   - directory: directory the object was originally persisted in
    ///   - newDirectory: new directory to store object in
    static func move(_ name: String, in directory: Directory, to newDirectory: Directory) {
        let fileName = validateFileName(name)
        if let currentUrl = getExistingFileURL(for: fileName, with: [.none, .json, .png, .jpg, .directory], in: directory) {
            let justDirectoryPath = createURL(for: directory, name: nil, extension: nil).path
            let filePath = currentUrl.path.replacingOccurrences(of: justDirectoryPath, with: "")
            let newUrl = createURL(for: newDirectory, name: filePath, extension: nil)
            do {
                try FileManager.default.moveItem(at: currentUrl, to: newUrl)
            } catch {
                printError(error.localizedDescription)
            }
        } else {
            printError("\"\(name)\" does not exist in \(directory.rawValue)")
        }
    }
    
    /// Rename a persisted object in the file system
    ///
    /// - Parameters:
    ///   - name: original name given to object
    ///   - directory: directory the object is persisted in
    ///   - newName: new name to give to persisted object
    static func rename(_ name: String, in directory: Directory, to newName: String) {
        let oldFileName = validateFileName(name)
        let newFileName = validateFileName(newName)
        if let currentUrl = getExistingFileURL(for: oldFileName, with: [.none, .json, .png, .jpg, .directory], in: directory) {
            let justDirectoryPath = createURL(for: directory, name: nil, extension: nil).path // add "/" here?
            let oldFilePath = currentUrl.path.replacingOccurrences(of: justDirectoryPath, with: "")
            let newFilePath = oldFilePath.replacingOccurrences(of: oldFileName, with: newFileName)
            let newUrl = createURL(for: directory, name: newFilePath, extension: nil)
            do {
                try FileManager.default.moveItem(at: currentUrl, to: newUrl)
            } catch {
                printError(error.localizedDescription)
            }
        } else {
            printError("\"\(name)\" does not exist in \(directory.rawValue)")
        }
    }
}
