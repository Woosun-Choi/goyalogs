//
//  PhotoSelectViewController.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 28..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit
import Photos
import RealmSwift

class PhotoSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var delegate: PhotoSelectDelgate!
    
    
    //MARK: Variable
    var selectedImage = [UIImage]()
    var willsaveImage = [UIImage]()
    var removalImage = [Image]()
    
     //var selectedIndexs = [Int]()
    
    @IBOutlet weak var resultCollectionView: resultCollectionview!
    @IBOutlet weak var dataCollectionView: dataCollectionView!
    //Variable end
    
    //MARK: Recive images from NoteView
    func sendThumbImages(images: [UIImage]) {
        selectedImage = images
    }
    
    func sendwillsaveImages(images: [UIImage]) {
        willsaveImage = images
    }
    
    func removalImages(images: [Image]) {
        removalImage = images
    }
    //
    
    @IBAction func cancelButton(_ sender: Any) {
        
        
        let sendwillsaveImages : [UIImage] = willsaveImage
        let sendselectedImages : [UIImage] = selectedImage
        
        print(willsaveImage.count)
        
        //MARK: Image save method
        
        delegate?.returnselectedImages(sendselectedImages)
        delegate?.returnwillsaveImages(sendwillsaveImages)
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: get document's directory
    func getDocumentDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let directory = path.last
        
        return directory!
    }
    
    //MARK: Call Camera for direct capture
    @IBAction func directCaptureButton(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                imagePicker.delegate = self
                present(imagePicker, animated: false, completion: nil )
                
            } else {
                
                let alert = UIAlertController(title: "Your phone doesn't have a rear camera!", message: "cannot access the camera.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            let alert = UIAlertController(title: "Cannot access your camera", message: "cannot access the camera.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataCollectionView.delegate = self
        dataCollectionView.dataSource = self
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        
        self.view.addSubview(dataCollectionView)
        self.view.addSubview(resultCollectionView)
        
        dataCollectionView.getPhoto()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == dataCollectionView {
            return dataCollectionView.imagesArray.count
        } else {
            return selectedImage.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.dataCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath)
            
            let imageView = cell.viewWithTag(1) as! UIImageView
            
            imageView.image = dataCollectionView.imagesArray[indexPath.row]
            
            /*cell.layer.borderColor = UIColor.white.cgColor
            if selectedIndexs.first(where: { $0 == indexPath.row }) != nil {
                cell.layer.borderWidth = 2.0
            } else {
                cell.layer.borderWidth = 0
            }*/
        
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultCell", for: indexPath as IndexPath)
            
            let resultView = cell.viewWithTag(1) as! UIImageView
            
            resultView.image = selectedImage[indexPath.row]
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.dataCollectionView {
            
            //let cell = dataCollectionView.cellForItem(at: indexPath)
                
            if let index = selectedImage.index(of: dataCollectionView.imagesArray[indexPath.row]) {
                
                selectedImage.remove(at: index)
                willsaveImage.remove(at: index)
                
                //selectedIndexs.remove(at: index)
                //cell!.layer.borderWidth = 0
                
            } else {
                
                selectedImage.append(dataCollectionView.imagesArray[indexPath.row])
                
                //MARK: To Save High quality image
                let imgManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.deliveryMode = .highQualityFormat
                    
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
                    
                if let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
                        if fetchResault.count > 0 {
                            imgManager.requestImage(for: fetchResault.object(at: indexPath.row), targetSize: CGSize(width: 640, height: 640), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                                image, error in
                                
                                self.willsaveImage.append(image!)
                            })
                    }
                }

                //selectedIndexs.append(indexPath.row)
                //cell!.layer.borderWidth = 2.0
            }
            
            self.resultCollectionView.reloadData()
            self.dataCollectionView.reloadData()
        }
        
        else {
            
            if let index = selectedImage.index(of: selectedImage[indexPath.row]) {
                
                selectedImage.remove(at: index)
                willsaveImage.remove(at: index)
            }
            
            self.resultCollectionView.reloadData()
            self.dataCollectionView.reloadData()
        }
    }
    
    
    //MARK: Cell layout settings
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 4 - 7.5
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
    }
    //Cell layout end
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // UIImagePickerControllerDelegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.insertImage(image: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func insertImage(image: UIImage) {
        selectedImage.append(image)
        willsaveImage.append(image)
        print(selectedImage.count)
        resultCollectionView.reloadData()
    }
    
}

