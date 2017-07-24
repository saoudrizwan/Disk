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
    ///   - data: array of Data to store to disk
    ///   - directory: directory to create folder with data objects
    ///   - name: name to give folder that will be created for data objects
    static func store(_ data: [Data], to directory: Directory, as name: String) {
        let fileName = validateFileName(name)
        let directoryUrl = createURL(for: directory, name: fileName, extension: .directory)
        // If directory exists with name, then remove it
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: directoryUrl.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                do {
                    printError("Folder with name \"\(name)\" already exists in \(directory.rawValue). Removing and replacing with contents of new data...")
                    try FileManager.default.removeItem(at: directoryUrl)
                } catch {
                    printError(error.localizedDescription)
                    return
                }
            }
        }
        // Create new directory with name
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
        } catch {
            printError(error.localizedDescription)
            return
        }
        // Create files and store in folder
        for i in 0..<data.count {
            let dataObject = data[i]
            let dataObjectName = "/\(i)"
            let dataObjectUrl = directoryUrl.appendingPathComponent(dataObjectName, isDirectory: false)
            do {
                if FileManager.default.fileExists(atPath: dataObjectUrl.path) {
                    try FileManager.default.removeItem(at: dataObjectUrl)
                }
                FileManager.default.createFile(atPath: dataObjectUrl.path, contents: dataObject, attributes: nil)
            } catch {
                printError(error.localizedDescription)
                continue
            }
        }
    }
    
    /// Retrieve an array of Data objects from disk
    ///
    /// - Parameters:
    ///   - name: name of folder that's holding the Data objects
    ///   - directory: directory where folder was created for holding Data objects
    ///   - type: here for Swifty generics magic, use [Data].self
    /// - Returns: [Disk] from disk
    static func retrieve(_ name: String, from directory: Directory, as type: [Data].Type) -> [Data]? {
        let fileName = validateFileName(name)
        guard let url = getExistingFileURL(for: fileName, with: [.directory], in: directory) else {
            printError("No folder found with name \"\(name)\" in \(directory.rawValue)")
            return nil
        }
        var objects = [Data]()
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in fileUrls {
                if let data = FileManager.default.contents(atPath: fileUrl.path) {
                    objects.append(data)
                } else {
                    printError("No data at \(url.path)")
                    continue
                }
            }
        } catch {
            printError(error.localizedDescription)
            return nil
        }
        return objects
    }
}

