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
    /// Save image to disk
    ///
    /// - Parameters:
    ///   - value: image to store to disk
    ///   - directory: user directory to store the image file in
    ///   - path: file location to store the data (i.e. "Folder/file.png")
    /// - Throws: Error if there were any issues writing the image to disk
    static func save(_ value: UIImage, to directory: Directory, as path: String) throws {
        do {
            var imageData: Data
            if path.suffix(4).lowercased() == ".png" {
                if let data = UIImagePNGRepresentation(value) {
                    imageData = data
                } else {
                    throw createError(
                        .serialization,
                        description: "Could not serialize UIImage to PNG.",
                        failureReason: "Data conversion failed.",
                        recoverySuggestion: "Try saving this image as a .jpg or without an extension at all."
                    )
                }
            } else if path.suffix(4).lowercased() == ".jpg" || path.suffix(5).lowercased() == ".jpeg" {
                if let data = UIImageJPEGRepresentation(value, 1) {
                    imageData = data
                } else {
                    throw createError(
                        .serialization,
                        description: "Could not serialize UIImage to JPEG.",
                        failureReason: "Data conversion failed.",
                        recoverySuggestion: "Try saving this image as a .png or without an extension at all."
                    )
                }
            } else {
                if let data = UIImagePNGRepresentation(value) {
                    imageData = data
                } else if let data = UIImageJPEGRepresentation(value, 1) {
                    imageData = data
                } else {
                    throw createError(
                        .serialization,
                        description: "Could not serialize UIImage to Data.",
                        failureReason: "UIImage could not serialize to PNG or JPEG data.",
                        recoverySuggestion: "Make sure image is not corrupt or try saving without an extension at all."
                    )
                }
            }
            let url = try createURL(for: path, in: directory)
            try createSubfoldersBeforeCreatingFile(at: url)
            try imageData.write(to: url, options: .atomic)
        } catch {
            throw error
        }
    }
    
    /// Retrieve image from disk
    ///
    /// - Parameters:
    ///   - path: path where image is stored
    ///   - directory: user directory to retrieve the image file from
    ///   - type: here for Swifty generics magic, use UIImage.self
    /// - Returns: UIImage from disk
    /// - Throws: Error if there were any issues retrieving the specified image
    static func retrieve(_ path: String, from directory: Directory, as type: UIImage.Type) throws -> UIImage {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw createError(
                    .deserialization,
                    description: "Could not decode UIImage from \(url.path).",
                    failureReason: "A UIImage could not be created out of the data in \(url.path).",
                    recoverySuggestion: "Try deserializing \(url.path) manually after retrieving it as Data."
                )
            }
        } catch {
            throw error
        }
    }
}


