//
//  Disk+Data.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Save Data to disk
    ///
    /// - Parameters:
    ///   - value: Data to store to disk
    ///   - directory: directory to store file with specified data
    ///   - path: file location to store the data (i.e. "Folder/file.mp4")
    /// - Throws: Error if there were any issues writing the given data to disk
    static func save(_ value: Data, to directory: Directory, as path: String) throws {
        do {
            let url = try createURL(for: path, in: directory)
            try createSubfoldersBeforeCreatingFile(at: url)
            FileManager.default.createFile(atPath: url.path, contents: value, attributes: nil)
        } catch {
            throw error
        }
    }
    
    /// Retrieve data from disk
    ///
    /// - Parameters:
    ///   - path: path where data file is stored
    ///   - directory: directory where data file is stored
    ///   - type: here for Swifty generics magic, use Data.self
    /// - Returns: Data retrived from disk
    /// - Throws: Error if there were any issues retrieving the specified file's data
    static func retrieve(_ path: String, from directory: Directory, as type: Data.Type) throws -> Data {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            if let data = FileManager.default.contents(atPath: url.path) {
                return data
            } else {
                throw createError(
                    .deserialization,
                    description: "No Data found in \(directory.rawValue)/\(path).",
                    failureReason: "Data could not be retrieved from \(directory.rawValue)/\(path).",
                    recoverySuggestion: "Write data to \(directory.rawValue)/\(path) before trying to retrieve it."
                )
            }
        } catch {
            throw error
        }
    }
}

