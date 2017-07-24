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
    ///   - images: array of images to store
    ///   - directory: directory to store images
    ///   - name: name to give folder that will be created to store the images
    static func store(_ images: [UIImage], to directory: Directory, as name: String) {
        let url = getURL(for: directory, path: name)
        // If directory exists with name, then remove it
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    printError(error.localizedDescription)
                    return
                }
            }
        }
        // Create new directory with name
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            printError(error.localizedDescription)
            return
        }
        for i in 0..<images.count {
            let image = images[i]
            let imageName = "/\(i)"
            var imageData: Data!
            var imageFileName: String!
            if let data = UIImagePNGRepresentation(image) {
                imageData = data
                imageFileName = imageName + ".png"
            } else if let data = UIImageJPEGRepresentation(image, 1) {
                imageData = data
                imageFileName = imageName + ".jpg"
            } else {
                printError("Could not convert image \(i) to PNG or JPEG")
                continue
            }
            let imageUrl = url.appendingPathComponent(imageFileName, isDirectory: false)
            do {
                if FileManager.default.fileExists(atPath: imageUrl.path) {
                    try FileManager.default.removeItem(at: imageUrl)
                }
                FileManager.default.createFile(atPath: imageUrl.path, contents: imageData, attributes: nil)
            } catch {
                printError(error.localizedDescription)
                continue
            }
        }
    }
    
    /// Retrieve an array of images from a folder on disk
    ///
    /// - Parameters:
    ///   - name: name of folder on disk
    ///   - directory: directory where images folder was created
    ///   - type: here for Swifty generics magic, use UIImage.self
    /// - Returns: [UIImage] from disk
    /// - Throws: Error if Disk could not retrieve images from folder at specified location on disk
    static func retrieve(_ name: String, from directory: Directory, as type: [UIImage].Type) -> [UIImage]? {
        let url = getURL(for: directory, path: name).appendingPathComponent("/", isDirectory: false)
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                printError("No folder with images found at \(url.path)")
                return nil
            }
        } else {
            printError("No folder with images found at \(url.path)")
            return nil
        }
        var images = [UIImage]()
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in files {
                if let data = FileManager.default.contents(atPath: fileUrl.path) {
                    if let image = UIImage(data: data) {
                        images.append(image)
                    } else {
                        printError("Could not convert data at \(fileUrl.path) to UIImage")
                        continue
                    }
                } else {
                    printError("No data at \(fileUrl.path)")
                    continue
                }
            }
        } catch {
            printError(error.localizedDescription)
            return nil
        }
        return images
    }
}

