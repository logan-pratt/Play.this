//
//  SongsHelper.swift
//  PlayThis
//
//  Created by Logan Pratt on 8/4/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import RealmSwift
import Realm

class RealmString: Object {
    @objc dynamic var stringValue = ""
}

class SongsHelper: NSObject {
    
    @objc static let sharedInstance = SongsHelper()
    
    @objc let defaults = UserDefaults.standard
    
    let realm = try! Realm()
    
    var groupCode: String = ""
    var currentSongIndex = 0
    var songs: [Song] = []
    var likedSongs: [Song] = []{
        didSet {
            let likedData = NSKeyedArchiver.archivedData(withRootObject: likedSongs.map({$0.id}))
            defaults.set(likedData, forKey: groupCode)
            defaults.synchronize()
            
//            try! realm.write {
//                realm.deleteAll()
//                for key in likedSongs.map({RealmString(value: [$0.key])}) {
//                    realm.add(key)
//                }
//            }
        }
    }
}
