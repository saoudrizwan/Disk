//
//  Disk+Codable.swift
//  Disk
//
//  Created by Saoud Rizwan http://saoudmr.com
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Store encodable struct to disk
    ///
    /// - Parameters:
    ///   - value: the Encodable struct to store
    ///   - directory: where to store the struct
    ///   - name: what to name the file where the struct data will be stored
    /// - Throws: Error if there were any issues writing the given struct to disk
    static func store<T: Encodable>(_ value: T, to directory: Directory, as name: String) throws {
        do {
            if fileExists(name, in: directory) {
                try remove(name, from: directory)
            }
            let url = createURL(for: name, extension: .json, in: directory)
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            throw error
        }
    }
    
    /// Retrieve and convert struct from a file on disk
    ///
    /// - Parameters:
    ///   - name: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self or [Message].self)
    /// - Returns: decoded struct model(s) of data
    /// - Throws: Error if there were any issues retrieving the specified file's data as the specified type
    static func retrieve<T: Decodable>(_ name: String, from directory: Directory, as type: T.Type) throws -> T {
        do {
            let url = try getOneExistingFileURL(for: name, with: [.json, .none], in: directory)
            if let data = FileManager.default.contents(atPath: url.path) {
                let decoder = JSONDecoder()
                let value = try decoder.decode(type, from: data)
                return value
            } else {
                throw createDiskError(
                    .deserialization,
                    description: "Did not retrieve Decodable data from \(name) in \(directory.rawValue).",
                    failureReason: "No data at \(name) in \(directory.rawValue) for JSONDecoder to decode to \(type).",
                    recoverySuggestion: "Write data to \(name) in \(directory.rawValue) before trying to retrieve and decode it as \(type)."
                )
            }
        } catch {
            throw error
        }
    }
}

