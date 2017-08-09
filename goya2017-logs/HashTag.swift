//
//  HashTag.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 27..
//  Copyright © 2017년 goya. All rights reserved.
//

import Foundation
import RealmSwift

class HashTag: Object {
    dynamic var name = ""
    let notes = List<Note>()
}
