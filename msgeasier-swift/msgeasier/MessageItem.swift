//
//  MessageItem.swift
//  msgeasier
//
//  Created by Gina Hagg on 5/8/15.
//  Copyright (c) 2015 Gina Hagg. All rights reserved.
//

import Foundation
import UIKit

struct MessageItem{
    var name:String
    var photo:UIImage?
    var lastSeen:NSDate = NSDate()
    var msg: String?
}

