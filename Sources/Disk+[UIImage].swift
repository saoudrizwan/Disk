//
//  Disk+[UIImage].swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Save an array of images to disk
    ///
    /// - Parameters:
    ///   - value: array of images to store
    ///   - directory: directory to store images
    ///   - path: folder location to store the images (i.e. "Folder/")
    /// - Throws: Error if there were any issues creating a folder and writing the given images to it
    static func save(_ value: [UIImage], to directory: Directory, as path: String) throws {
        do {
            let folderUrl = try createURL(for: path, in: directory)
            try createSubfoldersBeforeCreatingFile(at: folderUrl)
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)
            for i in 0..<value.count {
                let image = value[i]
                var imageName = "\(i)"
                var imageData: Data
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
                FileManager.default.createFile(atPath: imageUrl.path, contents: imageData, attributes: nil)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve an array of images from a folder on disk
    ///
    /// - Parameters:
    ///   - path: path of folder holding desired images
    ///   - directory: directory where images folder was created
    ///   - type: here for Swifty generics magic, use [UIImage].self
    /// - Returns: [UIImage] from disk
    /// - Throws: Error if there were any issues retrieving the specified folder of images
    static func retrieve(_ path: String, from directory: Directory, as type: [UIImage].Type) throws -> [UIImage] {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            var images = [UIImage]()
            for i in 0..<fileUrls.count {
                let fileUrl = fileUrls[i]
                if let data = FileManager.default.contents(atPath: fileUrl.path), let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            return images
        } catch {
            throw error
        }
    }
}

