//
//  Disk+Errors.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/25/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

extension Disk {
    public enum ErrorCode: Int {
        case noFileFound = 1
        case tooManyFilesFound = 2
        case serialization = 3
        case deserialization = 4
        case invalidFileName = 5
        case couldNotFindHomeDirectory = 6
    }
    
    public static let errorDomain = "DiskErrorDomain"
    
    /// Create custom error that File Manager can't account for
    static func createError(_ errorCode: ErrorCode, description: String?, failureReason: String?, recoverySuggestion: String?) -> Error {
        let errorInfo: [String: Any] = [NSLocalizedDescriptionKey : description ?? "",
                                        NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion ?? "",
                                        NSLocalizedFailureReasonErrorKey: failureReason ?? ""]
        return NSError(domain: errorDomain, code: errorCode.rawValue, userInfo: errorInfo) as Error
    }
}

