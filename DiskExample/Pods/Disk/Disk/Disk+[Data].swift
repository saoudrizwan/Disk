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
        let url = getURL(for: directory, path: name)
        // If directory exists with name, then remove it
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    printError(error.localizedDescription)
                    return
                }
            }
        }
        // Create new directory with name
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            printError(error.localizedDescription)
            return
        }
        for i in 0..<data.count {
            let dataObject = data[i]
            let dataObjectName = "/\(i)"
            let dataObjectUrl = url.appendingPathComponent(dataObjectName, isDirectory: false)
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
        let url = getURL(for: directory, path: name)
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                printError("No folder with data files found at \(url.path)")
                return nil
            }
        } else {
            printError("No folder with data files found at \(url.path)")
            return nil
        }
        var objects = [Data]()
        do {
            for fileUrl in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []) {
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

