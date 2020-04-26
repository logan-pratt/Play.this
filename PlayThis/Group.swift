//
//  Group.swift
//  PlayThis
//
//  Created by Logan Pratt on 1/22/17.
//  Copyright © 2020 Logan Pratt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Group {
    
    let key: String
    let name: String
    let ref: DatabaseReference?
    var songs: [String]
    
    init() {
        key = ""
        name = ""
        ref = nil
        songs = []
    }
    
    init(name: String, key: String) {
        self.key = key
        self.name = name
        self.ref = nil
        self.songs = []
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        print(key)
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        songs = snapshotValue["songs"] as! [String]
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "songs": songs
        ]
    }
    
}
