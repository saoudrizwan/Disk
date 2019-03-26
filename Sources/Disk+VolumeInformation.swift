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

/// Checking Volume Storage Capacity
/// Confirm that you have enough local storage space for a large amount of data.
///
/// Source: https://developer.apple.com/documentation/foundation/nsurlresourcekey/checking_volume_storage_capacity?changes=latest_major&language=objc
@available(iOS 11.0, *)
public extension Disk {
    /// Helper method to query against a resource value key
    private static func getVolumeResourceValues(for key: URLResourceKey) -> URLResourceValues? {
        let fileUrl = URL(fileURLWithPath: "/")
        let results = try? fileUrl.resourceValues(forKeys: [key])
        return results
    }
    
    /// Volume’s total capacity in bytes.
    static var totalCapacity: Int? {
        get {
            let resourceValues = getVolumeResourceValues(for: .volumeTotalCapacityKey)
            return resourceValues?.volumeTotalCapacity
        }
    }
    
    /// Volume’s available capacity in bytes.
    static var availableCapacity: Int? {
        get {
            let resourceValues = getVolumeResourceValues(for: .volumeAvailableCapacityKey)
            return resourceValues?.volumeAvailableCapacity
        }
    }
    
    /// Volume’s available capacity in bytes for storing important resources.
    ///
    /// Indicates the amount of space that can be made available  for things the user has explicitly requested in the app's UI (i.e. downloading a video or new level for a game.)
    /// If you need more space than what's available - let user know the request cannot be fulfilled.
    static var availableCapacityForImportantUsage: Int? {
        get {
            let resourceValues = getVolumeResourceValues(for: .volumeAvailableCapacityForImportantUsageKey)
            if let result = resourceValues?.volumeAvailableCapacityForImportantUsage {
                return Int(exactly: result)
            } else {
                return nil
            }
        }
    }
    
    /// Volume’s available capacity in bytes for storing nonessential resources.
    ///
    /// Indicates the amount of space available for things that the user is likely to want but hasn't explicitly requested (i.e. next episode in video series they're watching, or recently updated documents in a server that they might be likely to open.)
    /// For these types of files you might store them initially in the caches directory until they are actually used, at which point you can move them in app support or documents directory.
    static var availableCapacityForOpportunisticUsage: Int? {
        get {
            let resourceValues = getVolumeResourceValues(for: .volumeAvailableCapacityForOpportunisticUsageKey)
            if let result = resourceValues?.volumeAvailableCapacityForOpportunisticUsage {
                return Int(exactly: result)
            } else {
                return nil
            }
        }
    }
}
