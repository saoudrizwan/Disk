//
//  Post.swift
//  DiskExample
//
//  Created by Saoud Rizwan on 7/23/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
