//
//  HashTagView.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 27..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit

class HashTagView: UIView {
    
    let tagItem = UILabel()

    func designItem() {
        tagItem.layer.backgroundColor = UIColor.blue.cgColor
        tagItem.layer.cornerRadius = 3
        //tagItem.backgroundColor = UIColor.blue
        tagItem.textColor = UIColor.white
        
        self.addSubview(tagItem)
    }
    
    func setName(_ name: String) -> CGFloat {
        let str = NSString(string: "# " + name)
        let attribute = [NSFontAttributeName: tagItem.font]
        let size = str.size(attributes: attribute)
        
        designItem()
        tagItem.text = str as String
        tagItem.frame = CGRect(x: 0, y: 0, width: size.width, height: 24)
        
        return size.width
    }
}
