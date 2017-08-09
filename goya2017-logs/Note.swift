//
//  Note.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 27..
//  Copyright © 2017년 goya. All rights reserved.
//

import Foundation
import RealmSwift

class Note: Object {
    dynamic var text = ""
    dynamic var date = Date()
    let hashtag = LinkingObjects(fromType: HashTag.self, property: "notes")
    var images = List<Image>()
}
