//
//  Group.swift
//  PlayThis
//
//  Created by Logan Pratt on 1/22/17.
//  Copyright © 2017 Logan Pratt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

struct Group {
    
    let key: String
    let name: String
    let ref: DatabaseReference?
    var songs: [String]
    //let code: String
    
    init() {
        key = ""
        name = ""
        ref = nil
        songs = []
    }
    
    init(name: String, key: String) {
        self.key = key
        self.name = name
        //self.code = code
        self.ref = nil
        self.songs = []
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        print(key)
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        //code = snapshotValue["code"] as! String
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
