//
//  PlaylistViewController.swift
//  PlayThis
//
//  Created by Logan Pratt on 7/13/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
//import Parse
import SwiftyJSON
//import Spring
//import IJReachability
//import RJImageLoader

import Firebase
import FirebaseDatabase
import Realm
import RealmSwift

//import DropDownMenuKit

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistNavBar: UINavigationBar!
    @IBOutlet weak var playlistNavBarItem: UINavigationItem!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    @IBOutlet weak var nothingHereLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var copyGroupCodeButton: UIButton!
    @objc var refreshControl = UIRefreshControl()
    //var titleView: DropDownTitleView!
    //    var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .ballTrianglePath)
    
    
    let songsInstance = SongsHelper.sharedInstance
    let playbackInstance = PlaybackHelper.sharedInstance
    let ref = Database.database().reference(withPath: "songs")
    var defaults = UserDefaults.standard
    let realm = try! Realm()
    var likedSongs: [String] = []
    var firstRun = true
    var groupName = ""
    var groupCode = ""
    var songObjIds: [String] = []
    var tableNum = 0
    var playbackViewController: PlaybackViewController!
    
    var attr: [String : AnyObject]? = [NSAttributedString.Key.foregroundColor.rawValue:UIColor.white, NSAttributedString.Key.font.rawValue:UIFont(name: "Avenir-Light", size: 12.0)!]
 
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        playlistNavBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        playlistNavBar.shadowImage = UIImage()
        playlistNavBarItem.title = groupName
        
        nothingHereLabel.isHidden = true
        //        activityIndicatorView.center = view.center
        
        //        self.view.addSubview(activityIndicatorView)
        //        activityIndicatorView.startAnimation()
        
        groupCodeLabel.text = "Group code: \(groupCode)"
 
        
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
//        refreshControl.tintColor = UIColor.white
//        refreshControl.addTarget(self, action: #selector(PlayThisViewController.setUpTableView(_:)), for: UIControlEvents.valueChanged)
//        tableView?.addSubview(refreshControl)
        
//        for r in realm.objects(RealmString.self) {
//            likedSongs.append(r.stringValue)
//        }
        
        
        if let likedData = UserDefaults.standard.object(forKey: groupCode) as? NSData {
            likedSongs = (NSKeyedUnarchiver.unarchiveObject(with: likedData as Data) as? [String])!
        }
        
        setUpTableView(true)
        //        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown:")
        //        recognizer.direction = .Down
        //        self.view.addGestureRecognizer(recognizer)
 
        if !playbackInstance.player.items().isEmpty {
            nowPlayingButton.isEnabled = true
        }
    }
    
    @IBAction func copyGroupCode(_ sender: AnyObject) {
        UIPasteboard.general.string = groupCode
        copyGroupCodeButton.isEnabled = false
        copyGroupCodeButton.setTitle("Copied", for: UIControl.State())
    }
    
    @objc func setUpTableView(_ animated: Bool) {
        //if IJReachability.isConnectedToNetwork() {
        //        songTitles = []
        //        songArtists = []
        //        songCovers = []
        //        songIds = []
        //        songObjIds = []
        
        copyGroupCodeButton.isEnabled = true
        copyGroupCodeButton.setTitle("Copy", for: UIControl.State())
        
        ref.observe(.value, with: { snapshot in
            self.songsInstance.songs = []
            for item in snapshot.children {
                let song = Song(snapshot: item as! DataSnapshot)
                if(song.group == self.groupCode) {
                    self.songsInstance.songs.append(song)
                    if self.firstRun {
                        if self.likedSongs.contains(song.id) {
                            self.songsInstance.likedSongs.append(song)
                        }
                    }
                }
            }
            self.firstRun = false
            // print(self.songsInstance.likedSongs)
            //FINDS DUPLICATES
            //            if(Array(Set(self.songsInstance.songs.map({$0.likes}).filter({ (i: Int) in self.songsInstance.songs.filter({ $0.likes == i }).count > 1}))).count > 0) {
            //
            //            }
            self.songsInstance.songs = self.songsInstance.songs.sorted(by: {$0.likes > $1.likes})
            //            print(self.songsInstance.songs.map({$0.likes}))
            // 5
            //self.items = newItems
            
            self.tableView.reloadData()
        })
    }
    
    @IBAction func toSearch(_ sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let searchViewController = storyBoard.instantiateViewController(withIdentifier: "search") as! SearchViewController
        searchViewController.groupCode = groupCode
        self.present(searchViewController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToPlaylist(_ segue:UIStoryboardSegue) {
        setUpTableView(false)
    }
    
    @IBAction func showNowPlaying(_ sender: AnyObject) {
        if let _ = playbackViewController {
            self.present(playbackViewController, animated: true, completion: nil)
        } else {
            self.present(playbackInstance.storedPVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func animateTable() { // tableView cool animation
        tableView.reloadData()
        
        nothingHereLabel.isHidden = true
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        let cells = tableView.visibleCells
        
        for i in cells {
            let cell: UITableViewCell = i
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
    }
    
}

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        cell.setUpCell(song: songsInstance.songs[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsInstance.songs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        nowPlayingButton.isEnabled = true
        if playbackViewController == nil || playbackViewController.songId != songsInstance.songs[(indexPath as NSIndexPath).row].id {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            playbackViewController = storyBoard.instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
            print((indexPath as NSIndexPath).row)
            playbackViewController.currentSongIndex = (indexPath as NSIndexPath).row
        } else {
            playbackViewController.currentSongIndex = (indexPath as NSIndexPath).row
            playbackViewController.skipSong()
        }
        playbackInstance.storedPVC = playbackViewController
        self.present(playbackViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = self.songsInstance.songs[indexPath.row]
            song.ref?.removeValue()
        }
    }
    
}
