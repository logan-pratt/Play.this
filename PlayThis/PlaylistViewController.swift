//
//  PlaylistViewController.swift
//  PlayThis
//
//  Created by Logan Pratt on 7/13/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseDatabase

class PlaylistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playlistNavBar: UINavigationBar!
    @IBOutlet weak var playlistNavBarItem: UINavigationItem!
    @IBOutlet weak var nowPlayingButton: UIBarButtonItem!
    @IBOutlet weak var nothingHereLabel: UILabel!
    @IBOutlet weak var groupCodeLabel: UILabel!
    @IBOutlet weak var copyGroupCodeButton: UIButton!
    @objc var refreshControl = UIRefreshControl()
    
    let songsInstance = SongsHelper.sharedInstance
    var playbackInstance = PlaybackHelper.sharedInstance
    let ref = Database.database().reference(withPath: "songs")
    var defaults = UserDefaults.standard
    //let realm = try! Realm()
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
        
        groupCodeLabel.text = "Group code: \(groupCode)"
//        groupCodeLabel.text = "123456"
        
        if let likedData = UserDefaults.standard.object(forKey: groupCode) as? NSData {
            likedSongs = (NSKeyedUnarchiver.unarchiveObject(with: likedData as Data) as? [String])!
        }
        
        setUpTableView(true)
 
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
            
            self.songsInstance.songs = self.songsInstance.songs.sorted(by: {$0.likes > $1.likes})
            
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
    
    @IBAction func leaveGroup(_ sender: Any) {
        resetPlayback()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func resetPlayback() {
        playbackInstance.player.removeAllItems()
        if let pvc = playbackInstance.storedPVC {
            pvc.invalidateTimers()
            pvc.dismiss(animated: false, completion: nil)
            playbackInstance.storedPVC = nil
        }
        PlaybackHelper.sharedInstance = playbackInstance
        //songsInstance
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
        
        if let _ = playbackViewController {
            playbackViewController.dismiss(animated: false, completion: nil)
            resetPlayback()
        }
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        playbackViewController = storyBoard.instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
        playbackViewController.currentSongIndex = (indexPath as NSIndexPath).row
        
//        if playbackViewController == nil || playbackViewController.songId != songsInstance.songs[(indexPath as NSIndexPath).row].id {
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            playbackViewController = storyBoard.instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
//            print((indexPath as NSIndexPath).row)
//            playbackViewController.currentSongIndex = (indexPath as NSIndexPath).row
//        } else {
//            playbackViewController.currentSongIndex = (indexPath as NSIndexPath).row
//            playbackViewController.skipSong()
//        }
        
        
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
