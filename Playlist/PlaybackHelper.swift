//
//  PlaybackHelper.swift
//  Playlist
//
//  Created by Logan Pratt on 7/24/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVFoundation

class PlaybackHelper: NSObject {
   
    static let sharedInstance = PlaybackHelper()
    let songs = SongsHelper.sharedInstance
    
    var songId = ""
    var songTitle = ""
    var songArtist = ""
    var albumCover = UIImage()
    var currentSongIndex = 0
    var loadeditems = 0
    var isPlaying = true
    var duration: Float!
    var playlist: [String]!
    
    var timer: Timer!
    var playerStartedTimer: Timer!
    
    override init() {
        super.init()
        
    }
}
