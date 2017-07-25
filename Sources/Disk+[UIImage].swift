//
//  Disk+[UIImage].swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Store an array of images to disk
    ///
    /// - Parameters:
    ///   - value: array of images to store
    ///   - directory: directory to store images
    ///   - name: name to give folder that will be created to store the images
    /// - Throws: Error if there were any issues creating a folder and writing the given images to it
    static func store(_ value: [UIImage], to directory: Directory, as name: String) throws {
        do {
            if fileExists(name, in: directory) {
                try remove(name, from: directory)
            }
            let directoryUrl = createURL(for: name, extension: .directory, in: directory)
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false, attributes: nil)
            // Store images in this new directory
            for i in 0..<value.count {
                let image = value[i]
                let imageName = "\(i)"
                var imageData: Data
                var imageFileExtension: FileExtension
                if let data = UIImagePNGRepresentation(image) {
                    imageData = data
                    imageFileExtension = .png
                } else if let data = UIImageJPEGRepresentation(image, 1) {
                    imageData = data
                    imageFileExtension = .jpg
                } else {
                    throw createDiskError(
                        .serialization,
                        description: "Could not serialize UIImage \(i) in the array to Data.",
                        failureReason: "UIImage \(i) could not serialize to PNG or JPEG data.",
                        recoverySuggestion: "Make sure there are no corrupt images in the array."
                    )
                }
                let imageFileName = imageName + imageFileExtension.rawValue
                let imageUrl = directoryUrl.appendingPathComponent(imageFileName, isDirectory: false)
                FileManager.default.createFile(atPath: imageUrl.path, contents: imageData, attributes: nil)
            }
        } catch {
            throw error
        }
    }
    
    /// Retrieve an array of images from a folder on disk
    ///
    /// - Parameters:
    ///   - name: name of folder on disk
    ///   - directory: directory where images folder was created
    ///   - type: here for Swifty generics magic, use [UIImage].self
    /// - Returns: [UIImage] from disk
    /// - Throws: Error if there were any issues retrieving the specified folder of images
    static func retrieve(_ name: String, from directory: Directory, as type: [UIImage].Type) throws -> [UIImage] {
        //add / if it doesnt have it already
        do {
            let url = try getOneExistingFileURL(for: name, with: [.directory], in: directory)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            var images = [UIImage]()
            for i in 0..<fileUrls.count {
                let fileUrl = fileUrls[i]
                if let data = FileManager.default.contents(atPath: fileUrl.path), let image = UIImage(data: data) {
                    images.append(image)
                } else {
                    throw createDiskError(
                        .deserialization,
                        description: "Could not decode UIImage \(i) in \(name) in \(directory.rawValue).",
                        failureReason: "A UIImage could not be created out of the data in file \(i) in \(name) in \(directory.rawValue).",
                        recoverySuggestion: "Try deserializing \(name) in \(directory.rawValue) manually after retrieving it as [Data]."
                    )
                }
            }
            return images
        } catch {
            throw error
        }
    }
}

