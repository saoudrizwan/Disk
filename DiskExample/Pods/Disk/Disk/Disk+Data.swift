//
//  Disk+Data.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    
    /// Store Data to disk
    ///
    /// - Parameters:
    ///   - data: Data to store to disk
    ///   - directory: directory to store file with specified data
    ///   - name: name of file to hold specified data
    static func store(_ data: Data, to directory: Directory, as name: String) {
        let url = getURL(for: directory, path: name)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            printError(error.localizedDescription)
            return
        }
    }
    
    /// Retrieve data from disk
    ///
    /// - Parameters:
    ///   - name: name of file holding data
    ///   - directory: directory where data file is stored
    ///   - type: here for Swifty generics magic, use Data.self
    /// - Returns: Data retrived from disk
    static func retrieve(_ name: String, from directory: Directory, as type: Data.Type) -> Data? {
        let url = getURL(for: directory, path: name)
        if !FileManager.default.fileExists(atPath: url.path) {
            printError("File with path \(url.path) does not exist")
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            return data
        } else {
            printError("No data at \(url.path)")
            return nil
        }
    }
}

