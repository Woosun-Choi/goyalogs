//
//  NoteTableViewCell.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 27..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var rightImage: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var longText: UILabel!
    
    @IBOutlet weak var hashHolder: UIView!
    
    @IBOutlet weak var imageviewframe: UIView!
    var nowX = 0.0

    
    func setting(title: String, text: String) {
        self.title.text = title
        self.longText.text = text
    }
    
    func clearHashItem() {
        nowX = 0
        for subview in hashHolder.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func addHashItem(text: String) {
        let hash = HashTagView()
        let width = hash.setName(text)
        
        hash.frame = CGRect(x: nowX, y: 0.0, width: Double(width + 2.0), height: 24.0)
        
        hashHolder.addSubview(hash)
        nowX = Double(width + 4.0) + nowX
    }
    
    func displayRightImage(image: UIImage?) {
        rightImage.image = image
    }
}
