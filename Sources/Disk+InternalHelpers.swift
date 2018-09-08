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

extension Disk {
    /// Create and returns a URL constructed from specified directory/path
    static func createURL(for path: String?, in directory: Directory) throws -> URL {
        let filePrefix = "file://"
        var validPath: String? = nil
        if let path = path {
            do {
                validPath = try getValidFilePath(from: path)
            } catch {
                throw error
            }
        }
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        case .applicationSupport:
            searchPathDirectory = .applicationSupportDirectory
        case .temporary:
            if var url = URL(string: NSTemporaryDirectory()) {
                if let validPath = validPath {
                    url = url.appendingPathComponent(validPath, isDirectory: false)
                }
                if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
                    let fixedUrlString = filePrefix + url.absoluteString
                    url = URL(string: fixedUrlString)!
                }
                return url
            } else {
                throw createError(
                    .couldNotAccessTemporaryDirectory,
                    description: "Could not create URL for \(directory.pathDescription)/\(validPath ?? "")",
                    failureReason: "Could not get access to the application's temporary directory.",
                    recoverySuggestion: "Use a different directory."
                )
            }
        case .sharedContainer(let appGroupName):
            if var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName) {
                if let validPath = validPath {
                    url = url.appendingPathComponent(validPath, isDirectory: false)
                }
                if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
                    let fixedUrl = filePrefix + url.absoluteString
                    url = URL(string: fixedUrl)!
                }
                return url
            } else {
                throw createError(
                    .couldNotAccessSharedContainer,
                    description: "Could not create URL for \(directory.pathDescription)/\(validPath ?? "")",
                    failureReason: "Could not get access to shared container with app group named \(appGroupName).",
                    recoverySuggestion: "Check that the app-group name in the entitlement matches the string provided."
                )
            }
        }
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            if let validPath = validPath {
                url = url.appendingPathComponent(validPath, isDirectory: false)
            }
            if url.absoluteString.lowercased().prefix(filePrefix.count) != filePrefix {
                let fixedUrlString = filePrefix + url.absoluteString
                url = URL(string: fixedUrlString)!
            }
            return url
        } else {
            throw createError(
                .couldNotAccessUserDomainMask,
                description: "Could not create URL for \(directory.pathDescription)/\(validPath ?? "")",
                failureReason: "Could not get access to the file system's user domain mask.",
                recoverySuggestion: "Use a different directory."
            )
        }
    }
    
    /// Find an existing file's URL or throw an error if it doesn't exist
    static func getExistingFileURL(for path: String?, in directory: Directory) throws -> URL {
        do {
            let url = try createURL(for: path, in: directory)
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
            throw createError(
                .noFileFound,
                description: "Could not find an existing file or folder at \(url.path).",
                failureReason: "There is no existing file or folder at \(url.path)",
                recoverySuggestion: "Check if a file or folder exists before trying to commit an operation on it."
            )
        } catch {
            throw error
        }
    }
    
    /// Convert a user generated name to a valid file name
    static func getValidFilePath(from originalString: String) throws -> String {
        var invalidCharacters = CharacterSet(charactersIn: ":")
        invalidCharacters.formUnion(.newlines)
        invalidCharacters.formUnion(.illegalCharacters)
        invalidCharacters.formUnion(.controlCharacters)
        let pathWithoutIllegalCharacters = originalString
            .components(separatedBy: invalidCharacters)
            .joined(separator: "")
        let validFileName = removeSlashesAtBeginning(of: pathWithoutIllegalCharacters)
        guard validFileName.count > 0  && validFileName != "." else {
            throw createError(
                .invalidFileName,
                description: "\(originalString) is an invalid file name.",
                failureReason: "Cannot write/read a file with the name \(originalString) on disk.",
                recoverySuggestion: "Use another file name with alphanumeric characters."
            )
        }
        return validFileName
    }
    
    /// Helper method for getValidFilePath(from:) to remove all "/" at the beginning of a String
    static func removeSlashesAtBeginning(of string: String) -> String {
        var string = string
        if string.prefix(1) == "/" {
            string.remove(at: string.startIndex)
        }
        if string.prefix(1) == "/" {
            string = removeSlashesAtBeginning(of: string)
        }
        return string
    }
    
    /// Set 'isExcludedFromBackup' BOOL property of a file or directory in the file system
    static func setIsExcludedFromBackup(to isExcludedFromBackup: Bool, for path: String?, in directory: Directory) throws {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            var resourceUrl = url
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = isExcludedFromBackup
            try resourceUrl.setResourceValues(resourceValues)
        } catch {
            throw error
        }
    }
    
    /// Set 'isExcludedFromBackup' BOOL property of a file or directory in the file system
    static func setIsExcludedFromBackup(to isExcludedFromBackup: Bool, for url: URL) throws {
        do {
            var resourceUrl = url
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = isExcludedFromBackup
            try resourceUrl.setResourceValues(resourceValues)
        } catch {
            throw error
        }
    }
    
    /// Create necessary sub folders before creating a file
    static func createSubfoldersBeforeCreatingFile(at url: URL) throws {
        do {
            let subfolderUrl = url.deletingLastPathComponent()
            var subfolderExists = false
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: subfolderUrl.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    subfolderExists = true
                }
            }
            if !subfolderExists {
                try FileManager.default.createDirectory(at: subfolderUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
            throw error
        }
    }
    
    /// Get Int from a file name
    static func fileNameInt(_ url: URL) -> Int? {
        let fileExtension = url.pathExtension
        let filePath = url.lastPathComponent
        let fileName = filePath.replacingOccurrences(of: fileExtension, with: "")
        return Int(String(fileName.filter { "0123456789".contains($0) }))
    }
}
