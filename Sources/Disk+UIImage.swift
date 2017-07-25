//
//  Disk+UIImage.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Store image to disk
    ///
    /// - Parameters:
    ///   - value: image to store to disk
    ///   - directory: directory to store image in
    ///   - name: name to give to image file (don't need to include .png or .jpg extension)
    /// - Throws: Error if there were any issues writing the image to disk
    static func store(_ value: UIImage, to directory: Directory, as name: String) throws {
        do {
            if fileExists(name, in: directory) {
                try remove(name, from: directory)
            }
            var imageData: Data
            var imageFileExtension: FileExtension
            if let data = UIImagePNGRepresentation(value) {
                imageData = data
                imageFileExtension = .png
            } else if let data = UIImageJPEGRepresentation(value, 1) {
                imageData = data
                imageFileExtension = .jpg
            } else {
                throw createDiskError(
                    .serialization,
                    description: "Could not serialize UIImage to Data.",
                    failureReason: "UIImage could not serialize to PNG or JPEG data.",
                    recoverySuggestion: "Make sure image is not corrupt."
                )
            }
            let url = createURL(for: name, extension: imageFileExtension, in: directory)
            FileManager.default.createFile(atPath: url.path, contents: imageData, attributes: nil)
        } catch {
            throw error
        }
    }
    
    /// Retrive image from disk
    ///
    /// - Parameters:
    ///   - name: name of image on disk
    ///   - directory: directory where image is stored
    ///   - type: here for Swifty generics magic, use UIImage.self
    /// - Returns: UIImage from disk
    /// - Throws: Error if there were any issues retrieving the specified image
    static func retrieve(_ name: String, from directory: Directory, as type: UIImage.Type) throws -> UIImage {
        do {
            let url = try getOneExistingFileURL(for: name, with: [.png, .jpg, .none], in: directory)
            if let data = FileManager.default.contents(atPath: url.path), let image = UIImage(data: data) {
                return image
            } else {
                throw createDiskError(
                    .deserialization,
                    description: "Could not decode UIImage from \(name) in \(directory.rawValue).",
                    failureReason: "A UIImage could not be created out of the data in \(name) in \(directory.rawValue).",
                    recoverySuggestion: "Try deserializing \(name) in \(directory.rawValue) manually after retrieving it as Data."
                )
            }
        } catch {
            throw error
        }
    }
}


