//
//  Disk+UIImage.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Save image to disk
    ///
    /// - Parameters:
    ///   - value: image to store to disk
    ///   - directory: directory to store image in
    ///   - path: file location to store the data (i.e. "Folder/file.png")
    /// - Throws: Error if there were any issues writing the image to disk
    static func save(_ value: UIImage, to directory: Directory, as path: String) throws {
        do {
            var imageData: Data
            let suffix = path.suffix(4).lowercased()
            if suffix == ".png" {
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
            } else if suffix == ".jpg" {
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
            FileManager.default.createFile(atPath: url.path, contents: imageData, attributes: nil)
        } catch {
            throw error
        }
    }
    
    /// Retrive image from disk
    ///
    /// - Parameters:
    ///   - path: path where image is stored
    ///   - directory: directory where image is stored
    ///   - type: here for Swifty generics magic, use UIImage.self
    /// - Returns: UIImage from disk
    /// - Throws: Error if there were any issues retrieving the specified image
    static func retrieve(_ path: String, from directory: Directory, as type: UIImage.Type) throws -> UIImage {
        do {
            let url = try getExistingFileURL(for: path, in: directory)
            if let data = FileManager.default.contents(atPath: url.path), let image = UIImage(data: data) {
                return image
            } else {
                throw createError(
                    .deserialization,
                    description: "Could not decode UIImage from \(directory.rawValue)/\(path).",
                    failureReason: "A UIImage could not be created out of the data in  \(directory.rawValue)/\(path).",
                    recoverySuggestion: "Try deserializing \(directory.rawValue)/\(path) manually after retrieving it as Data."
                )
            }
        } catch {
            throw error
        }
    }
}


