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
        let jsonFileName = name + ".json"
        let url = getURL(for: directory, path: jsonFileName)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            printError(error.localizedDescription)
            return
        }
    }
    
    /// Retrieve and convert struct from a file on disk
    ///
    /// - Parameters:
    ///   - name: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ name: String, from directory: Directory, as type: T.Type) -> T? {
        var url: URL!
        let jsonUrl = getURL(for: directory, path: name + ".json")
        let withoutExtensionUrl = getURL(for: directory, path: name)
        if FileManager.default.fileExists(atPath: jsonUrl.path) {
            url = jsonUrl
        } else if FileManager.default.fileExists(atPath: withoutExtensionUrl.path) {
            url = withoutExtensionUrl
        } else {
            printError("Struct with name \(name) does not exist in \(directory.rawValue)")
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

