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
    ///   - model: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - name: what to name the file where the struct data will be stored
    static func store<T: Encodable>(_ model: T, to directory: Directory, as name: String) {
        let fileName = validateFileName(name)
        let url = createURL(for: directory, name: fileName, extension: .json)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            if FileManager.default.fileExists(atPath: url.path) {
                printError("File with name \"\(name)\" already exists in \(directory.rawValue). Removing and replacing with contents of new data...")
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            printError(error.localizedDescription)
        }
    }
    
    /// Retrieve and convert struct from a file on disk
    ///
    /// - Parameters:
    ///   - name: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self or [Message].self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ name: String, from directory: Directory, as type: T.Type) -> T? {
        let fileName = validateFileName(name)
        guard let url = getExistingFileURL(for: fileName, with: [.json, .none], in: directory) else {
            printError("Struct with name \"\(name)\" does not exist in \(directory.rawValue)")
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                printError(error.localizedDescription)
                return nil
            }
        } else {
            printError("No data at \(url.path)")
            return nil
        }
    }
}

