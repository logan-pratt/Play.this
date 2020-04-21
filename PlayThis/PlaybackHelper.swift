//
//  PlaybackHelper.swift
//  PlayThis
//
//  Created by Logan Pratt on 7/24/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVFoundation

class PlaybackHelper: NSObject {
   
    @objc static let sharedInstance = PlaybackHelper()
    @objc let songs = SongsHelper.sharedInstance
    @objc var player = AVQueuePlayer()
    
    @objc var songId = ""
    @objc var songTitle = ""
    @objc var songArtist = ""
    @objc var albumCover = UIImage()
    @objc var currentSongIndex = 0
    @objc var loadeditems = 0
    @objc var isPlaying = true
    var duration: Float!
    @objc var playlist: [String]!
    
    @objc var timer: Timer!
    @objc var playerStartedTimer: Timer!
    
    override init() {
        super.init()
        
    }
}
