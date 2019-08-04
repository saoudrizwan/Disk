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
    /// Save an array of Data objects to disk
    ///
    /// - Parameters:
    ///   - value: array of Data to store to disk
    ///   - directory: user directory to store the files in
    ///   - path: folder location to store the data files (i.e. "Folder/")
    /// - Throws: Error if there were any issues creating a folder and writing the given [Data] to files in it
    static func save(_ value: [Data], to directory: Directory, as path: String) throws {
        do {
            let folderUrl = try createURL(for: path, in: directory)
            try createSubfoldersBeforeCreatingFile(at: folderUrl)
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)
            for i in 0..<value.count {
                let data = value[i]
                let dataName = "\(i)"
                let dataUrl = folderUrl.appendingPathComponent(dataName, isDirectory: false)
                try data.write(to: dataUrl, options: .atomic)
            }
        } catch {
            throw error
        }
    }
    
    /// Append a file with Data to a folder
    ///
    /// - Parameters:
    ///   - value: Data to store to disk
    ///   - directory: user directory to store the file in
    ///   - path: folder location to store the data files (i.e. "Folder/")
    /// - Throws: Error if there were any issues writing the given data to disk
    static func append(_ value: Data, to path: String, in directory: Directory) throws {
        do {
            if let folderUrl = try? getExistingFileURL(for: path, in: directory) {
                let fileUrls = try FileManager.default.contentsOfDirectory(at: folderUrl, includingPropertiesForKeys: nil, options: [])
                var largestFileNameInt = -1
                for i in 0..<fileUrls.count {
                    let fileUrl = fileUrls[i]
                    if let fileNameInt = fileNameInt(fileUrl) {
                        if fileNameInt > largestFileNameInt {
                            largestFileNameInt = fileNameInt
                        }
                    }
                }
                let newFileNameInt = largestFileNameInt + 1
                let data = value
                let dataName = "\(newFileNameInt)"
                let dataUrl = folderUrl.appendingPathComponent(dataName, isDirectory: false)
                try data.write(to: dataUrl, options: .atomic)
            } else {
                let array = [value]
                try save(array, to: directory, as: path)
            }
        } catch {
            throw error
        }
    }
    
    /// Append an array of data objects as files to a folder
    ///
    /// - Parameters:
    ///   - value: array of Data to store to disk
    ///   - directory: user directory to create folder with data objects
    ///   - path: folder location to store the data files (i.e. "Folder/")
    /// - Throws: Error if there were any issues writing the given Data
    static func append(_ value: [Data], to path: String, in directory: Directory) throws {
        do {
            if let _ = try? getExistingFileURL(for: path, in: directory) {
                for data in value {
                    try append(data, to: path, in: directory)
                }
            } else {
                try save(value, to: directory, as: path)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve an array of Data objects from disk
    ///
    /// - Parameters:
    ///   - path: path of folder that's holding the Data objects' files
    ///   - directory: user directory where folder was created for holding Data objects
    ///   - type: here for Swifty generics magic, use [Data].self
    /// - Returns: [Data] from disk
    /// - Throws: Error if there were any issues retrieving the specified folder of files
    static func retrieve(_ path: String, from directory: Directory, as type: [Data].Type) throws -> [Data] {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            let sortedFileUrls = fileUrls.sorted(by: { (url1, url2) -> Bool in
                if let fileNameInt1 = fileNameInt(url1), let fileNameInt2 = fileNameInt(url2) {
                    return fileNameInt1 <= fileNameInt2
                }
                return true
            })
            var dataObjects = [Data]()
            for i in 0..<sortedFileUrls.count {
                let fileUrl = sortedFileUrls[i]
                let data = try Data(contentsOf: fileUrl)
                dataObjects.append(data)
            }
            return dataObjects
        } catch {
            throw error
        }
    }
}

