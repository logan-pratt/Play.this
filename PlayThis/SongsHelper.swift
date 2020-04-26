//
//  SongsHelper.swift
//  PlayThis
//
//  Created by Logan Pratt on 8/4/15.
//  Copyright (c) 2020 Logan Pratt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SongsHelper: NSObject {
    
    @objc static let sharedInstance = SongsHelper()
    @objc let defaults = UserDefaults.standard
    
    var apikey = ""
    var groupCode: String = ""
    var currentSongIndex = 0
    var songs: [Song] = []
    var likedSongs: [Song] = []{
        didSet {
            self.likedSongs = self.likedSongs.removingDuplicates()
            let likedData = NSKeyedArchiver.archivedData(withRootObject: likedSongs.map({$0.id}))
            defaults.set(likedData, forKey: groupCode)
            defaults.synchronize()
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
