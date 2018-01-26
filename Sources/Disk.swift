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

/**
 💾 Disk
 Easily work with the file system without worrying about any of its intricacies!
 
 - Save Codable structs, UIImage, [UIImage], Data, [Data] to Apple recommended locations on the user's disk, without having to worry about serialization.
 - Retrieve an object from disk as the type you specify, without having to worry about deserialization.
 - Remove specific objects from disk, clear entire directories if you need to, check if an object exists on disk, and much more!
 - Follow Apple's strict guidelines concerning persistence and using the file system easily.
 */
public class Disk {
    fileprivate init() { }
    
    public enum Directory: Equatable {
        /// Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory.
        /// Files in this directory are automatically backed up by iCloud. To disable this feature for a specific file, use the .doNotBackup(:in:) method.
        case documents
        
        /// Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        /// Use this directory to write any application-specific support files that you want to persist between launches of the application or during application updates. Your application is generally responsible for adding and removing these files. It should also be able to re-create these files as needed because iTunes removes them during a full restoration of the device. In iOS 2.2 and later, the contents of this directory are not backed up by iTunes.
        /// Note that the system may delete the Caches/ directory to free up disk space, so your app must be able to re-create or download these files as needed.
        case caches
        
        /// Put app-created support files in the <Application_Home>/Library/Application support directory. In general, this directory includes files that the app uses to run but that should remain hidden from the user. This directory can also include data files, configuration files, templates and modified versions of resources loaded from the app bundle.
        /// Files in this directory are automatically backed up by iCloud. To disable this feature for a specific file, use the .doNotBackup(:in:) method.
        case applicationSupport
        
        /// Data that is used only temporarily should be stored in the <Application_Home>/tmp directory. Although these files are not backed up to iCloud, remember to delete those files when you are done with them so that they do not continue to consume space on the user’s device.
        /// The system will periodically purge these files when your app is not running; therefore, you cannot rely on these files persisting after your app terminates.
        case temporary
        
        /// Sandboxed apps that need to share files with other apps from the same developer on a given device can use a shared container along with the com.apple.security.application-groups entitlement.
        /// The shared container or "app group" identifier string is used to locate the corresponding group's shared directory.
        /// For more details, visit https://developer.apple.com/documentation/foundation/nsfilemanager/1412643-containerurlforsecurityapplicati
        case sharedContainer(appGroupName: String)
        
        public var pathDescription: String {
            switch self {
            case .documents: return "<Application_Home>/Documents"
            case .caches: return "<Application_Home>/Library/Caches"
            case .applicationSupport: return "<Application_Home>/Library/Application"
            case .temporary: return "<Application_Home>/tmp"
            case .sharedContainer(let appGroupName): return "\(appGroupName)"
            }
        }
     
        static public func ==(lhs: Directory, rhs: Directory) -> Bool {
            switch (lhs, rhs) {
            case (.documents, .documents), (.caches, .caches), (.applicationSupport, .applicationSupport), (.temporary, .temporary):
                return true
            case (let .sharedContainer(appGroupName: name1), let .sharedContainer(appGroupName: name2)):
                return name1 == name2
            default:
                return false
            }
        }
     
    }
}
