//
//  UIImage+Extension.swift
//  Disk
//
//  Created by Saoud Rizwan on 8/21/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import UIKit

// UIImage's current Equatable implementation is buggy, this is a simply workaround to compare images' Data
extension UIImage {
    func dataEquals(_ otherImage: UIImage) -> Bool {
        if let selfData = self.pngData(), let otherData = otherImage.pngData() {
            return selfData == otherData
        } else {
            print("Could not convert images to PNG")
            return false
        }
    }
}
