//
//  Disk+[Data].swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Store an array of Data objects to disk
    ///
    /// - Parameters:
    ///   - value: array of Data to store to disk
    ///   - directory: directory to create folder with data objects
    ///   - name: name to give folder that will be created for data objects
    /// - Throws: Error if there were any issues creating a folder and writing the given Data to it
    static func store(_ value: [Data], to directory: Directory, as name: String) throws {
        do {
            if fileExists(name, in: directory) {
                try remove(name, from: directory)
            }
            let directoryUrl = createURL(for: name, extension: .directory, in: directory)
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
            // Store files in this new directory
            for i in 0..<value.count {
                let data = value[i]
                let dataName = "\(i)"
                let dataUrl = directoryUrl.appendingPathComponent(dataName, isDirectory: false)
                FileManager.default.createFile(atPath: dataUrl.path, contents: data, attributes: nil)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve an array of Data objects from disk
    ///
    /// - Parameters:
    ///   - name: name of folder that's holding the Data objects
    ///   - directory: directory where folder was created for holding Data objects
    ///   - type: here for Swifty generics magic, use [Data].self
    /// - Returns: [Disk] from disk
    /// - Throws: Error if there were any issues retrieving the specified folder of Data files
    static func retrieve(_ name: String, from directory: Directory, as type: [Data].Type) throws -> [Data] {
        do {
            let url = try getOneExistingFileURL(for: name, with: [.directory], in: directory)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            var dataObjects = [Data]()
            for i in 0..<fileUrls.count {
                let fileUrl = fileUrls[i]
                if let data = FileManager.default.contents(atPath: fileUrl.path) {
                    dataObjects.append(data)
                } else {
                    throw createDiskError(
                        .deserialization,
                        description: "Could not retrieved Data from file \(i) in \(name) in \(directory.rawValue).",
                        failureReason: "There's no readable Data in file \(i) in \(name) in \(directory.rawValue).",
                        recoverySuggestion: "Ensure that all the Data written to this folder in the first place has valid Data contents."
                    )
                }
            }
            return dataObjects
        } catch {
            throw error
        }
    }
}

