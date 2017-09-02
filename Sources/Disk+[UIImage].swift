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
    /// Save an array of images to disk
    ///
    /// - Parameters:
    ///   - value: array of images to store
    ///   - directory: user directory to store the images in
    ///   - path: folder location to store the images (i.e. "Folder/")
    /// - Throws: Error if there were any issues creating a folder and writing the given images to it
    static func save(_ value: [UIImage], to directory: Directory, as path: String) throws {
        do {
            let folderUrl = try createURL(for: path, in: directory)
            try createSubfoldersBeforeCreatingFile(at: folderUrl)
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)
            for i in 0..<value.count {
                let image = value[i]
                var imageData: Data
                var imageName = "\(i)"
                if let data = UIImagePNGRepresentation(image) {
                    imageData = data
                    imageName = imageName + ".png"
                } else if let data = UIImageJPEGRepresentation(image, 1) {
                    imageData = data
                    imageName = imageName + ".jpg"
                } else {
                    throw createError(
                        .serialization,
                        description: "Could not serialize UIImage \(i) in the array to Data.",
                        failureReason: "UIImage \(i) could not serialize to PNG or JPEG data.",
                        recoverySuggestion: "Make sure there are no corrupt images in the array."
                    )
                }
                let imageUrl = folderUrl.appendingPathComponent(imageName, isDirectory: false)
                try imageData.write(to: imageUrl, options: .atomic)
            }
        } catch {
            throw error
        }
    }
    
    /// Append an image to a folder
    ///
    /// - Parameters:
    ///   - value: image to store to disk
    ///   - path: folder location to store the image (i.e. "Folder/")
    ///   - directory: user directory to store the image file in
    /// - Throws: Error if there were any issues writing the image to disk
    static func append(_ value: UIImage, to path: String, in directory: Directory) throws {
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
                var imageData: Data
                var imageName = "\(newFileNameInt)"
                if let data = UIImagePNGRepresentation(value) {
                    imageData = data
                    imageName = imageName + ".png"
                } else if let data = UIImageJPEGRepresentation(value, 1) {
                    imageData = data
                    imageName = imageName + ".jpg"
                } else {
                    throw createError(
                        .serialization,
                        description: "Could not serialize UIImage to Data.",
                        failureReason: "UIImage could not serialize to PNG or JPEG data.",
                        recoverySuggestion: "Make sure image is not corrupt."
                    )
                }
                let imageUrl = folderUrl.appendingPathComponent(imageName, isDirectory: false)
                try imageData.write(to: imageUrl, options: .atomic)
            } else {
                let array = [value]
                try save(array, to: directory, as: path)
            }
        } catch {
            throw error
        }
    }
    
    /// Append an array of images to a folder
    ///
    /// - Parameters:
    ///   - value: images to store to disk
    ///   - path: folder location to store the images (i.e. "Folder/")
    ///   - directory: user directory to store the images in
    /// - Throws: Error if there were any issues writing the images to disk
    static func append(_ value: [UIImage], to path: String, in directory: Directory) throws {
        do {
            if let _ = try? getExistingFileURL(for: path, in: directory) {
                for image in value {
                    try append(image, to: path, in: directory)
                }
            } else {
                try save(value, to: directory, as: path)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve an array of images from a folder on disk
    ///
    /// - Parameters:
    ///   - path: path of folder holding desired images
    ///   - directory: user directory where images' folder was created
    ///   - type: here for Swifty generics magic, use [UIImage].self
    /// - Returns: [UIImage] from disk
    /// - Throws: Error if there were any issues retrieving the specified folder of images
    static func retrieve(_ path: String, from directory: Directory, as type: [UIImage].Type) throws -> [UIImage] {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            let sortedFileUrls = fileUrls.sorted(by: { (url1, url2) -> Bool in
                if let fileNameInt1 = fileNameInt(url1), let fileNameInt2 = fileNameInt(url2) {
                    return fileNameInt1 <= fileNameInt2
                }
                return true
            })
            var images = [UIImage]()
            for i in 0..<sortedFileUrls.count {
                let fileUrl = sortedFileUrls[i]
                let data = try Data(contentsOf: fileUrl)
                if let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            return images
        } catch {
            throw error
        }
    }

}

