//
//  SongTableViewCell.swift
//  Playlist
//
//  Created by Logan Pratt on 7/13/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
//import Parse

import FirebaseDatabase
import Firebase
import Kingfisher
 
//import Spring
import NVActivityIndicatorView
//import RJImageLoader

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    //    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), type: .BallTrianglePath)
    
    
    var songObjId = ""
    var groupCode = ""
    let songs = SongsHelper.sharedInstance
    var song: Song!
    var currentLikes: Int = 0
    var ref = Database.database().reference(withPath: "songs")
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCell(song: Song) {
       
        self.song = song
        if let checkedUrl = URL(string: song.coverURL) {
            albumCover.kf.setImage(with: checkedUrl)
            //downloadImage(checkedUrl)
        }

        songTitleLabel.text = song.name
        songArtistLabel.text = song.artist
        durationLabel.text = song.duration
        //songObjId = song.id
        
        likesLabel.text = "\(song.likes)"
        currentLikes = song.likes
        //print("\(song.name) has \(song.likes) likes")
        let songIsLiked = songs.likedSongs.map({$0.key}).contains(song.key)
        //print("isLiked \(songs.likedSongs.map({$0.name}))")
        //print(songIsLiked)
        if songIsLiked {
            likeButton.isSelected = true
        } else {
            likeButton.isSelected = false
        }
        //print(song.likes)
        // updateLikes()
        
    }
    
    
    func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data)
            }.resume()
    }
    
    func downloadImage(_ url:URL){
        getDataFromUrl(url) { data in
            DispatchQueue.main.async {
                self.albumCover.image = UIImage(data: data!)
            }
        }
    }
 
    
    func updateLikes() {
        //        let songsQuery = PFQuery(className: "Song")
        //        songsQuery.whereKey("objectId", equalTo: self.songObjId)
        //        songsQuery.findObjectsInBackground {(songs: [AnyObject]?, error: Error?) -> Void in
        //            if error == nil {
        //                if let songs = songs as? [PFObject] {
        //                    for song in songs {
        //                        let likes = song["likes"] as! Int
        //                        self.likesLabel.text = "\(likes)"
        //                    }
        //                }
        //            } else {
        //                print("Error: \(error!) \(error!._userInfo)")
        //            }
        //        }
    }
    
    @IBAction func likeSong(_ sender: AnyObject) {
        //        ref.child(song.key).val as! Int
        //ref.child(song.key).updateChildValues(["likes": "o"])
        
        //        ref.child(song.key).observeSingleEvent(of: .value, with: { (snapshot) in
        //            print(snapshot)
        //            self.currentLikes = (snapshot.childSnapshot(forPath: "likes").value as! NSNumber).intValue
        //
        if self.likeButton.isSelected {
            self.song.likes = Int(self.likesLabel.text!)! - 1
            self.songs.likedSongs = self.songs.likedSongs.filter() { $0.key != self.song.key }
            print("DESELECT \(self.songs.likedSongs.filter() { $0.key != self.song.key }.map({$0.name}))")
            self.likeButton.isSelected = false
        } else {
            self.song.likes = Int(self.likesLabel.text!)! + 1
            self.songs.likedSongs.append(self.song)
            self.likeButton.isSelected = true
        }
        self.ref.updateChildValues(["\(song.key)/likes": self.song.likes])
        print(self.song.likes)
        //        })
        //        let songsQuery = PFQuery(className: "Song")
        //        songsQuery.whereKey("objectId", equalTo: self.songObjId)
        //        songsQuery.findObjectsInBackground {(songs: [AnyObject]?, error: Error?) -> Void in
        //            if error == nil {
        //
        //                if let songs = songs as? [PFObject] {
        //                    for song in songs {
        //                        if self.likeButton.isSelected {
        //                            song["likes"] = song["likes"] as! Int - 1
        //                            self.songs.likedSongs = self.songs.likedSongs.filter() { $0 != self.songObjId}
        //                        } else {
        //                            song["likes"] = song["likes"] as! Int + 1
        //                            self.songs.likedSongs.append(self.songObjId)
        //                        }
        //                        self.likeButton.isSelected = !self.likeButton.isSelected
        //                        song.saveInBackground { (success: Bool, error: Error?) -> Void in
        //                            self.updateLikes()
        //                        }
        //                    }
        //                }
        //            } else {
        //                print("Error: \(error!) \(error!._userInfo)")
        //            }
        //        }
        
        
    }
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
