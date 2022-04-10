//
//  DiskErrors.h
//  Disk
//
//  Created by Sven Titgemeyer on 18.10.18.
//  Copyright © 2018 Saoud Rizwan. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Domain for Disk Errors.
///
/// Define Errors in Objective-C to get better Bridging between Swift/Objective-C.
/// Errors are imported as `DiskError` in Swift.
extern NSErrorDomain const DiskErrorDomain;
typedef NS_ERROR_ENUM(DiskErrorDomain, DiskError) {
    DiskErrorNoFileFound = 0,
    DiskErrorSerialization = 1,
    DiskErrorDeserialization = 2,
    DiskErrorInvalidFileName = 3,
    DiskErrorCouldNotAccessTemporaryDirectory = 4,
    DiskErrorCouldNotAccessUserDomainMask = 5,
    DiskErrorCouldNotAccessSharedContainer = 6
};
