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
    ///   - value: Data to store to disk
    ///   - directory: directory to store file with specified data
    ///   - name: name of file to hold specified data
    /// - Throws: Error if there were any issues writing the given data to disk
    static func store(_ value: Data, to directory: Directory, as name: String) throws {
        do {
            if fileExists(name, in: directory) {
                try remove(name, from: directory)
            }
            let url = createURL(for: name, extension: .none, in: directory)
            FileManager.default.createFile(atPath: url.path, contents: value, attributes: nil)
        } catch {
            throw error
        }
    }
    
    /// Retrieve data from disk
    ///
    /// - Parameters:
    ///   - name: name of file holding data
    ///   - directory: directory where data file is stored
    ///   - type: here for Swifty generics magic, use Data.self
    /// - Returns: Data retrived from disk
    /// - Throws: Error if there were any issues retrieving the specified file's data
    static func retrieve(_ name: String, from directory: Directory, as type: Data.Type) throws -> Data {
        do {
            let url = try getOneExistingFileURL(for: name, with: [.none, .json, .png, .jpg], in: directory)
            
            if let data = FileManager.default.contents(atPath: url.path) {
                return data
            } else {
                throw createDiskError(
                    .deserialization,
                    description: "No Data found in \(name) in \(directory.rawValue).",
                    failureReason: "Data could not be retrieved from \(name) in \(directory.rawValue).",
                    recoverySuggestion: "Write data to \(name) in \(directory.rawValue) before trying to retrieve it."
                )
            }
        } catch {
            throw error
        }
    }
}

