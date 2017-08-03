//
//  Song.swift
//  Playlist
//
//  Created by Logan Pratt on 1/22/17.
//  Copyright © 2017 Logan Pratt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import RealmSwift

class Song {
    
    let key: String
    var likes: Int
    let ref: DatabaseReference?
    let artist: String
    let name: String
    let coverURL: String
    var cover: UIImage?
    let group: String
    let id: String
    let duration: String
    
    init(group: String, name: String, artist: String, coverURL: String, id: String, key: String, duration: String, likes: Int = 0) {
        self.key = key
        self.likes = likes
        self.artist = artist
        self.name = name
        self.coverURL = coverURL
        self.ref = nil
        self.group = group
        self.id = id
        self.duration = duration.youtubeDuration
        downloadImage(URL(string:coverURL)!)
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        likes = (snapshotValue["likes"] as! NSNumber).intValue
        //code = snapshotValue["code"] as! String
        artist = snapshotValue["artist"] as! String
        name = snapshotValue["name"] as! String
        coverURL = snapshotValue["coverURL"] as! String
        ref = snapshot.ref
        group = snapshotValue["group"] as! String
        id = snapshotValue["id"] as! String
        duration = (snapshotValue["duration"] as! String).youtubeDuration
        downloadImage(URL(string:coverURL)!)
        print("done")
    }
    
    func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data)
            }.resume()
    }
    
    func downloadImage(_ url:URL){// -> UIImage{
        //        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        //var image = UIImage()
        print("QWERTY")
        getDataFromUrl(url) { data in
            //url.lastPathComponent.stringbydele
            DispatchQueue.main.async {
                                print("Finished downloading \"\(url.lastPathComponent)\".")
                self.cover = UIImage(data: data!)!
                print(self.cover!.size)
            }
        }
        //return image
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "artist": artist,
            "coverURL": coverURL,
            "group": group,
            "likes": likes,
            "id": id,
            "duration": duration
        ]
    }
}

extension String {
    var youtubeDuration: String {
        
        let formattedDuration = self.replacingOccurrences(of: "PT", with: "").replacingOccurrences(of: "H", with:":").replacingOccurrences(of: "M", with: ":").replacingOccurrences(of: "S", with: "")
        
        let components = formattedDuration.components(separatedBy: ":")
        var duration = ""
        for component in components {
            duration = duration.characters.count > 0 ? duration + ":" : duration
            if component.characters.count < 2 {
                duration += "0" + component
                continue
            }
            duration += component
        }
        
        if duration.components(separatedBy: ":").last?.characters.count == 1 {
            if(duration.characters.last == "0") {
                duration += "0"
            }
        }
        //print(duration)
        
        return duration
    }
}
