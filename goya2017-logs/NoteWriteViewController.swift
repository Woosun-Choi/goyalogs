//
//  NoteWriteViewController.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 27..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation

class NoteWriteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPageViewControllerDataSource, PhotoSelectDelgate {
    
    var PageVC: UIPageViewController! = nil
    var willsaveImage = [UIImage]()
    var selectedImage = [UIImage]()
    var hashTagList = Set<String>()
    var note: Note! = nil

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var imagePageViewConstrintsHeight: NSLayoutConstraint!
    @IBOutlet weak var textFeildConstraintWidth: NSLayoutConstraint!
    @IBOutlet weak var textFeildConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomItemViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomItemView: UIView!
    @IBOutlet weak var imagePageView: UIView!
    
    var imageData = [Image]()

    func returnwillsaveImages(_ images: [UIImage]) {
        
        willsaveImage = images

        reloadPageView()
    }
    
    func returnselectedImages(_ images: [UIImage]) {
        
        selectedImage = images
    }
    
    //MARK: set image Data
    func setimageData(_ images: [Image]) {
        imageData = images
    }
    
    func setwillsaveImage(images: [UIImage]) {
        willsaveImage = images
        print(willsaveImage.count)
    }
    
    func setselectedImages(images: [UIImage]) {
        selectedImage = images
    }
    
    func reloadPageView() {
        
        var ViewController = NSArray()
        
        if willsaveImage.count == 0 {
            self.imagePageViewConstrintsHeight.constant = 0
            self.textFeildConstraintHeight.constant = view.bounds.height - 150
        } else {
            let InitialView = ContentVCIndex(index: 0)
            self.imagePageViewConstrintsHeight.constant = view.bounds.width/2
            self.textFeildConstraintHeight.constant = view.bounds.height - self.imagePageViewConstrintsHeight.constant - 150
            ViewController = NSArray(object: InitialView)
            PageVC.setViewControllers(ViewController as? [UIViewController], direction: .forward, animated: true, completion: nil)
        }

    }
    
    //keyboardAction
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //self.view.frame.origin.y -= keyboardSize.height
                
                if willsaveImage.count != 0 {
                    self.imagePageViewConstrintsHeight.constant = 0
                    self.textFeildConstraintHeight.constant = view.bounds.height - imagePageViewConstrintsHeight.constant - 100 - keyboardSize.height
                    self.view.layoutIfNeeded()
            }
        }
        
        //self.bottomItemViewConstraintHeight.constant = 0
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //self.view.frame.origin.y += keyboardSize.height
                
                if willsaveImage.count != 0 {
                    self.imagePageViewConstrintsHeight.constant = view.bounds.width/2
                    self.textFeildConstraintHeight.constant = view.bounds.height - imagePageViewConstrintsHeight.constant - 150
                    self.view.layoutIfNeeded()
                }
            }
        
        //self.bottomItemViewConstraintHeight.constant = 65
    }
    
    func doneClicked() {
        view.endEditing(true)
    }
    
    // get document's directory
    func getDocumentDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let directory = path.last
        
        return directory!
    }
    
    func setData(_ note: Note) {
        self.note = note
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        //print(hashTagList)
        
        //MARK: get imageData file counts to remove
        let deleteindex : Int = imageData.count - 1
        
        //MARK: make new imageData
        for image in willsaveImage {
            
            let name = self.hashCreate(length: 32)
            
            do {
                let doc = getDocumentDirectory() + "/img"
                try FileManager.default.createDirectory(atPath: doc, withIntermediateDirectories: false, attributes: nil)
            } catch _ as NSError {}
            
            let IMAGE_WIDTH = CGFloat(640)
            let imageRatio = image.size.width / IMAGE_WIDTH
            let filePath = getDocumentDirectory() + "/img/" + name + ".jpg"
            let imageRect = CGRect(x: 0, y: 0, width: IMAGE_WIDTH, height: (image.size.height / imageRatio))
            
            UIGraphicsBeginImageContext(imageRect.size)
            image.draw(in: imageRect)
            
            let ctx = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            do {
                let jpgImage = UIImageJPEGRepresentation(ctx!, 0.8)
                try jpgImage?.write(to: URL(fileURLWithPath: filePath))
            } catch _ as NSError {}
            
            
            let THUMBNAIL_IMAGE_WIDTH = CGFloat(200)
            let tempFilePath = getDocumentDirectory() + "/img/" + name + "-thumbnail.jpg"
            let tempImageRatio = image.size.width / THUMBNAIL_IMAGE_WIDTH
            let tempImageRect = CGRect(x: 0, y: 0, width: THUMBNAIL_IMAGE_WIDTH, height: (image.size.height / tempImageRatio))
            
            UIGraphicsBeginImageContext(tempImageRect.size)
            image.draw(in: tempImageRect)
            
            let tempImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            do {
                let jpgImage = UIImageJPEGRepresentation(tempImage!, 0.8)
                try jpgImage?.write(to: URL(fileURLWithPath: tempFilePath))
            } catch let error as NSError {
                print(error)
            }
            
            //MARK: Save image to realm
            
            let realm = try! Realm()
            
            try! realm.write {
                let obj = Image()
                obj.fileName = name
                
                realm.add(obj)
                imageData.append(obj)
            }
        }
        
        for index in 0...deleteindex {
            let path = getDocumentDirectory() + "/img/" + imageData[index].fileName + ".jpg"
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch _ as NSError {}
            let thumbpath = getDocumentDirectory() + "/img/" + imageData[index].fileName + "-thumbnail.jpg"
            do {
                try FileManager.default.removeItem(atPath: thumbpath)
            } catch _ as NSError {}
        }
        
        for _ in 0...deleteindex {
            imageData.remove(at: 0)
        }
        
        print(imageData.count)
        
        let realm = try! Realm()
        
        try! realm.write {
            
            if note != nil {
                self.note.text = textField.text
                self.note.date = Date()
                
                self.note.images.removeAll()
                
                for img in imageData {
                    self.note.images.append(img)
                }
                //realm.delete(note)
            }
            
            else {
            
                note = realm.create(Note.self)
                note.text = textField.text
                note.date = Date()
            
                for img in imageData {
                    note.images.append(img)
                }
            }
        }
        
        for hashString in hashTagList {
            let predicate = NSPredicate(format: "name = %@", hashString)
            let hashtags = realm.objects(HashTag.self).filter(predicate)
            if hashtags.isEmpty {
                try! realm.write {
                    let hashObject = realm.create(HashTag.self)
                    hashObject.name = hashString
                    hashObject.notes.append(note)
                }
            } else {
                try! realm.write {
                    let hashObject = hashtags.first
                    hashObject?.notes.append(note)
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func hashCreate(length: Int) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randString = ""
        
        for _ in 0..<length {
            let randNum = Int(arc4random_uniform(UInt32(base.characters.count)))
            let s = base.index(base.startIndex, offsetBy: randNum)
            let e = base.index(base.startIndex, offsetBy: randNum + 1)
            randString += String(base[s ..< e])
        }
        
        return randString
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFeildConstraintWidth.constant = view.bounds.width - 20
        
        //MARK: Keyboardsettings
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.backgroundColor = UIColor.clear
        keyboardToolbar.barTintColor = UIColor.darkGray
        
        let flexibleSapce = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        doneButton.tintColor = UIColor.white
        
        keyboardToolbar.setItems([flexibleSapce, doneButton], animated: false)
        
        
        textField.inputAccessoryView = keyboardToolbar
        
        
        //MARK: Note data write
        if note != nil {
            textField.text = note.text
            for hashtag in note.hashtag {
                hashTagList.insert(hashtag.name)
            }
            
            for img in note.images {
                imageData.append(img)
            }
        }
        
        
        //MARK: Subview Settings
        PageVC = self.storyboard?.instantiateViewController(withIdentifier: "PageVC") as! UIPageViewController
        PageVC.view.frame = imagePageView.bounds
        imagePageView.addSubview(PageVC.view)
        addChildViewController(PageVC)
        PageVC.didMove(toParentViewController: self)
        PageVC.dataSource = self
        
        reloadPageView()
        
    }
    
    //MARK: pageview
    
    func ContentVCIndex(index: Int) -> ContentViewController {
        
        if willsaveImage.count == 0 || index >= willsaveImage.count {
            return ContentViewController()
        } else {
            
            let ContentVC  = self.storyboard?.instantiateViewController(withIdentifier: "ContentVC") as! ContentViewController
            //let path = getDocumentDirectory() + "/img/" + ContentImageData[index].fileName + ".jpg"
            //let uiImage = UIImage(contentsOfFile: path)
            
            ContentVC.PageIndex = index
            ContentVC.ContentImage = willsaveImage[index]
            
            return ContentVC
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let ContentVC = viewController as! ContentViewController
        var PageIndex = ContentVC.PageIndex as Int
        
        if PageIndex == 0 || PageIndex == NSNotFound {
            
            return nil
            
        }
        
        PageIndex -= 1
        
        return ContentVCIndex(index: PageIndex)
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let ContentVC = viewController as! ContentViewController
        var PageIndex = ContentVC.PageIndex as Int
        
        if PageIndex == NSNotFound {
            
            return nil
            
        }
        
        PageIndex += 1
        
        if PageIndex == willsaveImage.count {
            
            return nil
            
        }
        
        return ContentVCIndex(index: PageIndex)
        
        
    }
    
    //pageveiw end
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePageView.backgroundColor = UIColor(patternImage: image)
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func openLibrary(_ sender: Any) {
        
        let vc = UIImagePickerController()
        
        vc.sourceType = .photoLibrary
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageExist(_ sender: Any) {
        self.imagePageViewConstrintsHeight.constant = 100
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    

    @IBAction func imageClear(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        var inputField: UITextField!
        
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: { action in
            self.hashTagList.insert(inputField.text!)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter text:"
            inputField = textField
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoteToPhoto" {
            let vc = segue.destination as! PhotoSelectViewController
            vc.delegate = self
            
            if willsaveImage.count != 0 {
                
                var images = [UIImage]()
                var thumbs = [UIImage]()
                
                images = willsaveImage
                thumbs = selectedImage
                
                vc.sendThumbImages(images: thumbs)
                vc.sendwillsaveImages(images: images)
                
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
