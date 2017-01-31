//
//  PlaylistViewController.swift
//  Playlist
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
import DropDownMenuKit

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistNavBar: UINavigationBar!
    @IBOutlet weak var playlistNavBarItem: UINavigationItem!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    @IBOutlet weak var nothingHereLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var copyGroupCodeButton: UIButton!
    var refreshControl = UIRefreshControl()
    var titleView: DropDownTitleView!
    //    var activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .ballTrianglePath)
    
    let songsInstance = SongsHelper.sharedInstance
    let ref = FIRDatabase.database().reference(withPath: "songs")
    var defaults = UserDefaults.standard
    let realm = try! Realm()
    var likedSongs: [String] = []
    var firstRun = true
    var groupName = ""
    var groupCode = ""
    //    var songIds: [String] = [] {
    //        didSet {
    //            songsInstance.songIds = songIds
    //        }
    //    }
    //    var songTitles: [String] = [] {
    //        didSet {
    //            songsInstance.songTitles = songTitles
    //        }
    //    }
    //    var songCovers: [String] = [] {
    //        didSet {
    //            songsInstance.songCovers = songCovers
    //        }
    //    }
    //    var songArtists: [String] = [] {
    //        didSet {
    //            songsInstance.songArtists = songArtists
    //        }
    //    }
    
    var songObjIds: [String] = []
    var tableNum = 0
    var playbackViewController: PlaybackViewController!
    
    var attr: [String : AnyObject]? = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:UIFont(name: "Avenir-Light", size: 12.0)!]
    
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
//        refreshControl.addTarget(self, action: #selector(PlaylistViewController.setUpTableView(_:)), for: UIControlEvents.valueChanged)
//        tableView?.addSubview(refreshControl)
        
        for r in realm.objects(RealmString.self) {
            likedSongs.append(r.stringValue)
        }
        
        setUpTableView(true)
        //        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDown:")
        //        recognizer.direction = .Down
        //        self.view.addGestureRecognizer(recognizer)
    }
    
    @IBAction func copyGroupCode(_ sender: AnyObject) {
        UIPasteboard.general.string = groupCode
        copyGroupCodeButton.isEnabled = false
        copyGroupCodeButton.setTitle("Copied", for: UIControlState())
    }
    
    func setUpTableView(_ animated: Bool) {
        //if IJReachability.isConnectedToNetwork() {
        //        songTitles = []
        //        songArtists = []
        //        songCovers = []
        //        songIds = []
        //        songObjIds = []
        
        copyGroupCodeButton.isEnabled = true
        copyGroupCodeButton.setTitle("Copy", for: UIControlState())
        
        ref.observe(.value, with: { snapshot in
            self.songsInstance.songs = []
            for item in snapshot.children {
                let song = Song(snapshot: item as! FIRDataSnapshot)
                if(song.group == self.groupCode) {
                    self.songsInstance.songs.append(song)
                    if self.firstRun {
                        if self.likedSongs.contains(song.key) {
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
        
        //        let query = ref.queryOrdered(byChild: "group").queryEqual(toValue: groupCode)
        //        query.observe(.value, with: { (snapshot) in
        //            for child in snapshot.children {
        //                let child = child as! FIRDataSnapshot
        //                if let childVal = child.value as? [String: AnyObject] {
        //                    self.songs.append(Song(group: self.groupCode, name: childVal["name"] as! String, artist: childVal["artist"] as! String, coverURL: childVal["coverURL"] as! String, id: childVal["id"] as! String, key: child.key))
        //                }
        //
        //                //print(snapshot.childSnapshot(forPath: "name").value as! String)
        //            }
        ////            self.tableView.
        //        })
        
        //            let query = PFQuery(className: "Group")
        //            query.whereKey("groupCode", equalTo: groupCode)
        //            query.findObjectsInBackground {(groups: [AnyObject]?, error: NSError?) -> Void in
        //                if error == nil {
        //                    if let groups = groups as? [PFObject] {
        //                        for group in groups {
        //                            let songsQuery = PFQuery(className: "Song")
        //                            songsQuery.whereKey("group", equalTo: group)
        //                            songsQuery.order(byDescending: "likes")
        //                            songsQuery.findObjectsInBackground {(songs: [AnyObject]?, error: NSError?) -> Void in
        //                                if error == nil {
        //                                    if let songs = songs as? [PFObject] {
        //                                        for song in songs {
        //                                            let songId = song["songId"] as! String
        //                                            var songExists = false
        //
        //                                            for id in self.songIds {
        //                                                if id == songId {
        //                                                    songExists = true
        //                                                }
        //                                            }
        //
        //                                            if !songExists {
        //                                                self.songIds.append(songId)
        //                                                self.songObjIds.append(song.objectId!)
        //
        //                                                let songUrl = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=\(songId)&key=AIzaSyCwyQdce6OAUCXH_AEGSlkMIsG60e8BoRc"
        //                                                let url = URL(string: songUrl)
        //                                                let request = URLRequest(url: url!)
        //                                                let data = try? NSURLConnection.sendSynchronousRequest(request, returning: nil)
        //                                                if data != nil {
        //                                                    var json = JSON(data: data!)
        //                                                    if let songTitle = json["items", 0, "snippet", "title"].string {
        //                                                        if songTitle.range(of: " - ") != nil {
        //                                                            self.songTitles.append(songTitle.components(separatedBy: " - ")[1])
        //                                                            self.songArtists.append(songTitle.components(separatedBy: " - ")[0])
        //                                                        } else {
        //                                                            self.songTitles.append(songTitle)
        //
        //                                                            if let songArtist = json["items", 0, "snippet", "channelTitle"].string {
        //                                                                self.songArtists.append(songArtist)
        //                                                            }
        //                                                        }
        //                                                    }
        //                                                    if let songCover = json["items", 0, "snippet", "thumbnails", "high", "url"].string {
        //                                                        self.songCovers.append(songCover)
        //                                                    }
        //
        //                                                    if self.songTitles.count > 0 {
        //                                                        self.nothingHereLabel.isHidden = true
        //                                                        if animated {
        //                                                            self.animateTable()
        //                                                        } else {
        //                                                            self.tableView.reloadData()
        //                                                        }
        //                                                    } else {
        //                                                        self.nothingHereLabel.isHidden = false
        //                                                    }
        //
        //
        //                                                }
        //                                            }
        //
        //                                        }
        //                                    }
        //                                } else {
        //                                    // Log details of the failure
        //                                    print("Error: \(error!) \(error!.userInfo)")
        //                                }
        ////                                self.activityIndicatorView.stopAnimation()
        //                                self.refreshControl.endRefreshing()
        //                            }
        //
        //                        }
        //                    }
        //                } else {
        //                    // Log details of the failure
        //                    print("Error: \(error!) \(error!.userInfo)")
        //                }
        //            }HERE
        //        } else {
        //            refreshControl.attributedTitle = NSAttributedString(string: "No Internet Connection", attributes:attr)
        //            refreshControl.endRefreshing()
        //        }
        
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
        self.present(playbackViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animateTable() { // tableView cool animation
        tableView.reloadData()
        
        nothingHereLabel.isHidden = true
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        let cells = tableView.visibleCells
        
        for i in cells {
            let cell: UITableViewCell = i
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        //        var index = 0
        //
        //        for eachCell in cells {
        //            let cell: UITableViewCell = eachCell
        //            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
        //                cell.transform = CGAffineTransform(translationX: 0, y: 0);
        //                }, completion: nil)
        //
        //            index += 1
        //        }
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
            //            print(songCovers[(indexPath as NSIndexPath).row])
            //            playbackViewController.imageUrl = songs[(indexPath as NSIndexPath).row].coverURL
            //            playbackViewController.songArtist = songs[(indexPath as NSIndexPath).row].artist
            //            playbackViewController.songTitle = songs[(indexPath as NSIndexPath).row].name
            //            playbackViewController.songId = songs[(indexPath as NSIndexPath).row].id
            //HERE
            playbackViewController.currentSongIndex = (indexPath as NSIndexPath).row
        } else {
            PlaybackViewController.sharedInstance.currentSongIndex = (indexPath as NSIndexPath).row
            PlaybackViewController.sharedInstance.skipSong()
        }
        self.present(playbackViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let song = self.songsInstance.songs[indexPath.row]
            song.ref?.removeValue()
            //            let songObjId = songObjIds[(indexPath as NSIndexPath).row]
            //            songTitles.remove(at: (indexPath as NSIndexPath).row)
            //            songArtists.remove(at: (indexPath as NSIndexPath).row)
            //            songCovers.remove(at: (indexPath as NSIndexPath).row)
            //            songIds.remove(at: (indexPath as NSIndexPath).row)
            //            songObjIds.remove(at: (indexPath as NSIndexPath).row)
            //tableView.reloadData()
            //            DispatchQueue.main.async {
            //                let query = PFQuery(className: "Song")
            //                query.getObjectInBackground(withId: songObjId) {
            //                    (song: PFObject?, error: Error?) -> Void in
            //                    if error == nil {
            //                        song!.deleteInBackground {
            //                            (success: Bool, error: Error?) -> Void in
            //                            //self.setUpTableView(false)
            //                        }
            //                    } else {
            //                        print(error!)
            //                    }
            //                }
            //            }
        }
    }
    
}
