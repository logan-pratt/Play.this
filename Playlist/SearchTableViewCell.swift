//
//  SearchTableViewCell.swift
//  Playlist
//
//  Created by Logan Pratt on 7/17/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
//import Parse
import Firebase
import FirebaseDatabase

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var songCover: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var addSongButton: UIButton!
    @IBOutlet weak var addedLabel: UILabel!
    
    var songId = ""
    var groupCode = ""
    let songs = SongsHelper.sharedInstance
    var ref = FIRDatabase.database().reference()
    var song: Song? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setCode(_ code: String) {
        groupCode = code
    }
    
    func setUpCell(_ imageUrl: String, songTitle: String, songArtist: String, songId: String, code: String) {
        if let checkedUrl = URL(string: imageUrl) {
            downloadImage(checkedUrl)
        }
        song = Song(group: code, name: songTitle, artist: songArtist, coverURL: imageUrl, id: songId, key:"")
        songTitleLabel.text = songTitle
        songArtistLabel.text = songArtist
        self.songId = songId
        groupCode = code
        addSongButton.isHidden = false
        
        let songIsAdded = (songs.songs.filter() { $0.id == songId }.count > 0)
        
        if songIsAdded {
            addedLabel.isHidden = false
            addSongButton.isHidden = true
        } else {
            addedLabel.isHidden = true
            addSongButton.isHidden = false
        }
    }
    
    func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data)
            }.resume()
    }
    
    func downloadImage(_ url:URL){
//        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            DispatchQueue.main.async {
//                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.songCover.image = UIImage(data: data!)
            }
        }
    }

    
    @IBAction func addSong(_ sender: AnyObject) {
        addSongButton.isHidden = !addSongButton.isHidden
        addedLabel.isHidden = !addedLabel.isHidden

        let songRef = self.ref.child("songs")
        songRef.childByAutoId().setValue(song?.toAnyObject())

       // songRef.setValue(song?.toAnyObject())
        
        //groupRef.setValue(group.toAnyObject())
       // var group: Group;// = Group()
        //let groupRef = self.ref.child("groups").child(groupCode)
        //groupRef.value(forKeyPath: "")
        //groupRef.updateChildValues(["songs": groupRef.value])
//        let query = PFQuery(className: "Group")
//        query.whereKey("groupCode", equalTo: groupCode)
//        query.findObjectsInBackground {(groups: [AnyObject]?, error: Error?) -> Void in
//            
//            if error == nil {
//                if let groups = groups as? [PFObject] {
//                    for group in groups {
//                        let newSong = PFObject(className: "Song")
//                        newSong["songId"] = self.songId
//                        newSong["group"] = group
//                        newSong["likes"] = 0
//                        newSong.saveInBackground()
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!._userInfo)")
//            }
//        }HERE
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
