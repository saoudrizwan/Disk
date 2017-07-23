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
    ///   - image: image to store to disk
    ///   - directory: directory to store image in
    ///   - name: name to give to image file (don't need to include .png or .jpg extension)
    static func store(_ image: UIImage, to directory: Directory, as name: String) {
        var imageData: Data!
        var imageFileName: String!
        if let data = UIImagePNGRepresentation(image) {
            imageData = data
            imageFileName = name + ".png"
        } else if let data = UIImageJPEGRepresentation(image, 1) {
            imageData = data
            imageFileName = name + ".jpg"
        } else {
            fatalError("Could not convert image to PNG or JPEG")
        }
        let url = getURL(for: directory, path: imageFileName)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: imageData, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Retrive image from disk
    ///
    /// - Parameters:
    ///   - name: name of image on disk
    ///   - directory: directory where image is stored
    ///   - type: here for Swifty generics magic, use UIImage.self
    /// - Returns: UIImage from disk
    static func retrieve(_ name: String, from directory: Directory, as type: UIImage.Type) -> UIImage {
        var url: URL!
        let withoutExtensionUrl = getURL(for: directory, path: name)
        let pngUrl = getURL(for: directory, path: name + ".png")
        let jpgUrl = getURL(for: directory, path: name + ".jpg")
        if FileManager.default.fileExists(atPath: pngUrl.path) {
            url = pngUrl
        } else if FileManager.default.fileExists(atPath: jpgUrl.path) {
            url = jpgUrl
        } else if FileManager.default.fileExists(atPath: withoutExtensionUrl.path) {
            url = withoutExtensionUrl
        } else {
            fatalError("Image with name \(name) does not exist")
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            if let image = UIImage(data: data) {
                return image
            } else {
                fatalError("Could not convert image from data at \(url.path) to \(type)")
            }
        } else {
            fatalError("No data at \(url.path)")
        }
    }
}


