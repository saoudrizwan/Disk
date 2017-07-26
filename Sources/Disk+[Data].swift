//
//  Disk+[Data].swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Save an array of Data objects to disk
    ///
    /// - Parameters:
    ///   - value: array of Data to store to disk
    ///   - directory: directory to create folder with data objects
    ///   - path: folder location to store the data files (i.e. "Folder/")
    /// - Throws: Error if there were any issues creating a folder and writing the given Data to it
    static func save(_ value: [Data], to directory: Directory, as path: String) throws {
        do {
            let folderUrl = try createURL(for: path, in: directory)
            try createSubfoldersBeforeCreatingFile(at: folderUrl) // if we do this first, we don't have to pass true to 'withIntermediateDirectories' below
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)
            for i in 0..<value.count {
                let data = value[i]
                let dataName = "\(i)"
                let dataUrl = folderUrl.appendingPathComponent(dataName, isDirectory: false)
                FileManager.default.createFile(atPath: dataUrl.path, contents: data, attributes: nil)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve an array of Data objects from disk
    ///
    /// - Parameters:
    ///   - path: path of folder that's holding the Data objects' files
    ///   - directory: directory where folder was created for holding Data objects
    ///   - type: here for Swifty generics magic, use [Data].self
    /// - Returns: [Data] from disk
    /// - Throws: Error if there were any issues retrieving the specified folder of Data files
    static func retrieve(_ path: String, from directory: Directory, as type: [Data].Type) throws -> [Data] {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            var dataObjects = [Data]()
            for i in 0..<fileUrls.count {
                let fileUrl = fileUrls[i]
                if let data = FileManager.default.contents(atPath: fileUrl.path) {
                    dataObjects.append(data)
                }
            }
            return dataObjects
        } catch {
            throw error
        }
    }
}

