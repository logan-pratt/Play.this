//
//  SongsHelper.swift
//  Playlist
//
//  Created by Logan Pratt on 8/4/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SongsHelper: NSObject {
    
    static let sharedInstance = SongsHelper()
    //    var songIds: [String] = []
    //    var songTitles: [String] = []
    //    var songCovers: [String] = []
    //    var songArtists: [String] = []
    //    var likedSongs: [String] = []
    //    var coverImages: [UIImage] = []
    var currentSongIndex = 0
    var songs: [Song] = []
    var likedSongs: [Song] = []
    //    var key: String = ""
    //    var likes: Int = 0
    //    var ref: FIRDatabaseReference? = nil
    //    var artist: String = ""
    //    var name: String = ""
    //    var coverURL: String = ""
    //    var cover: UIImage? = UIImage()
    //    var group: String = ""
    //    var id: String = ""
    
    //    func addSong(group: String, name: String, artist: String, coverURL: String, id: String, key: String) {
    //
    //        self.key = key
    //        self.likes = 0
    //        self.artist = artist
    //        self.name = name
    //        self.coverURL = coverURL
    //        self.ref = nil
    //        self.group = group
    //        self.id = id
    //        self.cover = downloadImage(URL(string:coverURL)!)
    //    }
    
    func addSong(song: Song) {
        songs.append(song)
    }
    
    func addSong(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        songs.append(Song(group: snapshotValue["group"] as! String, name: snapshotValue["name"] as! String, artist: snapshotValue["artist"] as! String, coverURL: snapshotValue["coverURL"] as! String, id: snapshotValue["id"] as! String, key: snapshot.key))
        //        key = snapshot.key
        //        likes = snapshotValue["likes"] as! Int
        //        //code = snapshotValue["code"] as! String
        //        artist = snapshotValue["artist"] as! String
        //        name = snapshotValue["name"] as! String
        //        coverURL = snapshotValue["coverURL"] as! String
        //        ref = snapshot.ref
        //        group = snapshotValue["group"] as! String
        //        id = snapshotValue["id"] as! String
        //        cover = downloadImage(URL(string:coverURL)!)
    }
}
