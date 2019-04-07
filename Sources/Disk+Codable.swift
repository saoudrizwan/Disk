// The MIT License (MIT)
//
// Copyright (c) 2017 Saoud Rizwan <hello@saoudmr.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public extension Disk {
    /// Save encodable struct to disk as JSON data
    ///
    /// - Parameters:
    ///   - value: the Encodable struct to store
    ///   - directory: user directory to store the file in
    ///   - path: file location to store the data (i.e. "Folder/file.json")
    ///   - encoder: custom JSONEncoder to encode value
    /// - Throws: Error if there were any issues encoding the struct or writing it to disk
    static func save<T: Encodable>(_ value: T, to directory: Directory, as path: String, encoder: JSONEncoder = JSONEncoder()) throws {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            let url = try createURL(for: path, in: directory)
            let data = try encoder.encode(value)
            try createSubfoldersBeforeCreatingFile(at: url)
            try data.write(to: url, options: .atomic)
        } catch {
            throw error
        }
    }
    
    /// Append Codable struct JSON data to a file's data
    ///
    /// - Parameters:
    ///   - value: the struct to store to disk
    ///   - path: file location to store the data (i.e. "Folder/file.json")
    ///   - directory: user directory to store the file in
    ///   - decoder: custom JSONDecoder to decode existing values
    ///   - encoder: custom JSONEncoder to encode new value
    /// - Throws: Error if there were any issues with encoding/decoding or writing the encoded struct to disk
    static func append<T: Codable>(_ value: T, to path: String, in directory: Directory, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) throws {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            if let url = try? getExistingFileURL(for: path, in: directory) {
                let oldData = try Data(contentsOf: url)
                if !(oldData.count > 0) {
                    try save([value], to: directory, as: path, encoder: encoder)
                } else {
                    let new: [T]
                    if let old = try? decoder.decode(T.self, from: oldData) {
                        new = [old, value]
                    } else if var old = try? decoder.decode([T].self, from: oldData) {
                        old.append(value)
                        new = old
                    } else {
                        throw createDeserializationErrorForAppendingStructToInvalidType(url: url, type: value)
                    }
                    let newData = try encoder.encode(new)
                    try newData.write(to: url, options: .atomic)
                }
            } else {
                try save([value], to: directory, as: path, encoder: encoder)
            }
        } catch {
            throw error
        }
    }
    
    /// Append Codable struct array JSON data to a file's data
    ///
    /// - Parameters:
    ///   - value: the Codable struct array to store
    ///   - path: file location to store the data (i.e. "Folder/file.json")
    ///   - directory: user directory to store the file in
    ///   - decoder: custom JSONDecoder to decode existing values
    ///   - encoder: custom JSONEncoder to encode new value
    /// - Throws: Error if there were any issues writing the encoded struct array to disk
    static func append<T: Codable>(_ value: [T], to path: String, in directory: Directory, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) throws {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            if let url = try? getExistingFileURL(for: path, in: directory) {
                let oldData = try Data(contentsOf: url)
                if !(oldData.count > 0) {
                    try save(value, to: directory, as: path, encoder: encoder)
                } else {
                    let new: [T]
                    if let old = try? decoder.decode(T.self, from: oldData) {
                        new = [old] + value
                    } else if var old = try? decoder.decode([T].self, from: oldData) {
                        old.append(contentsOf: value)
                        new = old
                    } else {
                        throw createDeserializationErrorForAppendingStructToInvalidType(url: url, type: value)
                    }
                    let newData = try encoder.encode(new)
                    try newData.write(to: url, options: .atomic)
                }
            } else {
                try save(value, to: directory, as: path, encoder: encoder)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve and decode a struct from a file on disk
    ///
    /// - Parameters:
    ///   - path: path of the file holding desired data
    ///   - directory: user directory to retrieve the file from
    ///   - type: struct type (i.e. Message.self or [Message].self)
    ///   - decoder: custom JSONDecoder to decode existing values
    /// - Returns: decoded structs of data
    /// - Throws: Error if there were any issues retrieving the data or decoding it to the specified type
    static func retrieve<T: Decodable>(_ path: String, from directory: Directory, as type: T.Type, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        if path.hasSuffix("/") {
            throw createInvalidFileNameForStructsError()
        }
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let data = try Data(contentsOf: url)
            let value = try decoder.decode(type, from: data)
            return value
        } catch {
            throw error
        }
    }
}

extension Disk {
    /// Helper method to create deserialization error for append(:path:directory:) functions
    fileprivate static func createDeserializationErrorForAppendingStructToInvalidType<T>(url: URL, type: T) -> Error {
        return Disk.createError(
            .deserialization,
            description: "Could not deserialize the existing data at \(url.path) to a valid type to append to.",
            failureReason: "JSONDecoder could not decode type \(T.self) from the data existing at the file location.",
            recoverySuggestion: "Ensure that you only append data structure(s) with the same type as the data existing at the file location.")
    }
    
    /// Helper method to create error for when trying to saving Codable structs as multiple files to a folder
    fileprivate static func createInvalidFileNameForStructsError() -> Error {
        return Disk.createError(
            .invalidFileName,
            description: "Cannot save/retrieve the Codable struct without a valid file name. Unlike how arrays of UIImages or Data are stored, Codable structs are not saved as multiple files in a folder, but rather as one JSON file. If you already successfully saved Codable struct(s) to your folder name, try retrieving it as a file named 'Folder' instead of as a folder 'Folder/'",
            failureReason: "Disk does not save structs or arrays of structs as multiple files to a folder like it does UIImages or Data.",
            recoverySuggestion: "Save your struct or array of structs as one file that encapsulates all the data (i.e. \"multiple-messages.json\")")
    }
}

