//
//  dataCollectionView.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 30..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit
import Photos

class dataCollectionView: UICollectionView {

    var imagesArray = [UIImage]()
    var imageData = [Data]()
    
    func getPhoto() {
        
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        if let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            
            if fetchResault.count > 0 {
                for i in 0..<fetchResault.count {
                    imgManager.requestImage(for: fetchResault.object(at: i), targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        image, error in
                        
                        self.imagesArray.append(image!)
                        
                    })
                    
                }
                
            } else {
                print("You got no photos")
                self.reloadData()
            }
        }
    }
    
}
