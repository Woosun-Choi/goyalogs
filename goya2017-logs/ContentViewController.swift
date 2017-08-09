//
//  ContentViewController.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 28..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var ContentImageView: UIImageView!
    //MARK: Variable
    
    var PageIndex = Int()
    var ContentImage = UIImage()
    //Variable_end
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ContentImageView.image = ContentImage
        ContentImageView.bounds = ContentViewController.accessibilityFrame()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
