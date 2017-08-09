//
//  PhotoSelectDelegate.swift
//  goya2017-logs
//
//  Created by goya on 2017. 8. 3..
//  Copyright © 2017년 goya. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoSelectDelgate {
    func returnwillsaveImages(_ images: [UIImage])
    func returnselectedImages(_ images: [UIImage])
}
