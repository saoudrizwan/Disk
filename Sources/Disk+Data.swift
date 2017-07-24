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
        let fileName = validateFileName(name)
        let url = createURL(for: directory, name: fileName, extension: .none)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                printError("File with name \"\(name)\" already exists in \(directory.rawValue). Removing and replacing with contents of new data...")
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            printError(error.localizedDescription)
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
        let fileName = validateFileName(name)
        guard let url = getExistingFileURL(for: fileName, with: [.none, .json, .png, .jpg], in: directory) else {
            printError("File with name \"\(name)\" does not exist in \(directory.rawValue)")
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

