//
//  Disk+Codable.swift
//  Disk
//
//  Created by Saoud Rizwan http://saoudmr.com
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Save encodable struct to disk as JSON data
    ///
    /// - Parameters:
    ///   - value: the Encodable struct to store
    ///   - directory: where to store the struct
    ///   - path: file location to store the data (i.e. "Folder/file.json")
    /// - Throws: Error if there were any issues writing the encoded struct to disk
    static func save<T: Encodable>(_ value: T, to directory: Directory, as path: String) throws {
        do {
            let url = try createURL(for: path, in: directory)
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            try createSubfoldersBeforeCreatingFile(at: url)
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            throw error
        }
    }
    
    /// Retrieve and decode a struct from a file on disk
    ///
    /// - Parameters:
    ///   - path: path of the file holding desired data
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self or [Message].self)
    /// - Returns: decoded structs of data
    /// - Throws: Error if there were any issues retrieving the data or decoding it to the specified type
    static func retrieve<T: Decodable>(_ path: String, from directory: Directory, as type: T.Type) throws -> T {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            if let data = FileManager.default.contents(atPath: url.path) {
                let decoder = JSONDecoder()
                let value = try decoder.decode(type, from: data)
                return value
            } else {
                throw createError(
                    .deserialization,
                    description: "Did not retrieve Decodable data from \(directory.rawValue)/\(path).",
                    failureReason: "No data at \(directory.rawValue)/\(path) for JSONDecoder to successfully decode to \(type).",
                    recoverySuggestion: "Encode data to \(directory.rawValue)/\(path) before trying to retrieve and decode it as \(type)."
                )
            }
        } catch {
            throw error
        }
    }
}

