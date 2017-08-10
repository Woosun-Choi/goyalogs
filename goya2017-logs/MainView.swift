//
//  ViewController.swift
//  goya2017-logs
//
//  Created by goya on 2017. 7. 27..
//  Copyright © 2017년 goya. All rights reserved.
//

import UIKit
import RealmSwift

class MainView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var notes: [Note]!
    
    // get document's directory
    func getDocumentDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let directory = path.last
        
        return directory!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm()
        let noteObjects = realm.objects(Note.self).sorted(byKeyPath: "date", ascending: false)
        notes = Array(noteObjects)
        
        tableview.reloadData()
    }
    
    //MARK: cellsettings
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note_cell", for: indexPath) as! NoteTableViewCell
        let index = indexPath.row
        let note = notes[index]
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:DD"
        
        let title = df.string(from: note.date)
        cell.setting(title: note.text.components(separatedBy: CharacterSet.newlines).first! , text: title)
        
        if note.images.count != 0 {
            let path = getDocumentDirectory() + "/img/" + note.images[0].fileName + ".jpg"
            let image = UIImage(contentsOfFile: path)
            cell.displayRightImage(image: image!)
        } else {
            cell.displayRightImage(image: UIImage())
        }
        
        cell.clearHashItem()
        for hash in note.hashtag {
            cell.addHashItem(text: hash.name)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let note = notes[indexPath.row]
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(note)
                
            }
            
            notes.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        self.performSegue(withIdentifier: "NoteWrite", sender: note)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoteWrite" {
            let vc = segue.destination as! NoteWriteViewController
            let note = sender as! Note
            
            vc.setData(note)
            
            var willsave = [UIImage]()
            var selected = [UIImage]()
            
            for name in note.images {
             
             let path = getDocumentDirectory() + "/img/" + name.fileName + ".jpg"
             let image = UIImage(contentsOfFile: path)
             willsave.append(image!)
             
             let thumbPath = getDocumentDirectory() + "/img/" + name.fileName + "-thumbnail.jpg"
             let thumbnail = UIImage(contentsOfFile: thumbPath)
             selected.append(thumbnail!)
             
             }
            
            vc.setwillsaveImage(images: willsave)
            vc.setselectedImages(images: selected)
        }
    }

}

