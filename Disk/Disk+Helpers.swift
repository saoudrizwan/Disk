//
//  Disk+Helpers.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    
    /// Clear directory by removing all files
    ///
    /// - Parameter directory: directory to clear
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory, path: nil)
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Remove file with name from specified directory
    ///
    /// - Parameters:
    ///   - name: file name given to file to remove (without extension)
    ///   - directory: directory where file to remove is located
    static func remove(_ name: String, from directory: Directory) {
        let dataUrl = getURL(for: directory, path: name)
        let jsonUrl = getURL(for: directory, path: name + ".json")
        let pngUrl = getURL(for: directory, path: name + ".png")
        let jpgUrl = getURL(for: directory, path: name + ".jpg")
        let directoryUrl = getURL(for: directory, path: name + "/")
        
        for url in [dataUrl, jsonUrl, pngUrl, jpgUrl, directoryUrl] {
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    /// Checks if file exists at specified directory with specified file name
    ///
    /// - Parameters:
    ///   - name: name of file (without extension)
    ///   - directory: directory where file is located
    /// - Returns: Bool indicating whether file exists at specified directory with specified file name
    static func fileExists(_ name: String, in directory: Directory) -> Bool {
        let dataUrl = getURL(for: directory, path: name)
        let jsonUrl = getURL(for: directory, path: name + ".json")
        let pngUrl = getURL(for: directory, path: name + ".png")
        let jpgUrl = getURL(for: directory, path: name + ".jpg")
        let directoryUrl = getURL(for: directory, path: name + "/")
        
        var exists = false
        for url in [dataUrl, jsonUrl, pngUrl, jpgUrl, directoryUrl] {
            if FileManager.default.fileExists(atPath: url.path) {
                exists = true
            }
        }
        return exists
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
        var url = getURL(for: directory, path: name)
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try url.setResourceValues(resourceValues)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Sets the 'do not backup' attribute of the object on disk to false. This is the default behaviour so you don't have to use this function unless you already called doNotBackup(name:directory:) on a specific file.
    /// This default backing up behaviour allows anything in the .documents and .caches directories to be stored in backups made of the user's device (on iCloud or iTunes)
    ///
    /// - Parameters:
    ///   - name: name of object on disk
    ///   - directory: directory where object is stored
    static func backup(_ name: String, in directory: Directory) {
        var url = getURL(for: directory, path: name)
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = false
            try url.setResourceValues(resourceValues)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
