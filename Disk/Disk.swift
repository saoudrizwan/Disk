//
//  Disk.swift
//  Disk
//
//  Created by Saoud Rizwan http://saoudmr.com
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

/**
 💾 Disk v 0.0.1
 Easily work with the file system without worrying about any of its intricacies!
 
 - Store Codable structs, UIImage, [UIImage], Data, [Data] to Apple recommended locations on the user's disk
 - Retrieve an object from disk as the type you specify, without having to worry about conversion or casting
 - Remove specific objects from disk, clear entire directories if you need to, or check if an object exists on disk
 
 Data persistence has never been easier in Swift, and I hope Disk makes it evermore delightful!
 */
public class Disk {
    
    fileprivate init() { }
    
    // MARK: Directory URLs
    
    public enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents
        
        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        // Use this directory to write any application-specific support files that you want to persist between launches of the application or during application updates. Your application is generally responsible for adding and removing these files. It should also be able to re-create these files as needed because iTunes removes them during a full restoration of the device. In iOS 2.2 and later, the contents of this directory are not backed up by iTunes.
        // Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed.
        case caches
        
        // Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device.
        case temporary
    }
    
    // MARK: Class helper methods
    
    /// Returns URL constructed from specified directory
    static func getURL(for directory: Directory, path: String?) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        case .temporary:
            var temporaryUrl = FileManager.default.temporaryDirectory
            if let path = path {
                temporaryUrl = temporaryUrl.appendingPathComponent(path, isDirectory: false)
            }
            return temporaryUrl
        }
        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            if let path = path {
                url = url.appendingPathComponent(path, isDirectory: false)
            }
            return url
        } else {
            fatalError("Could not create URL for specified directory")
        }
    }
    
}
