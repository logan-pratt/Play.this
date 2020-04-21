//
//  SearchViewController.swift
//  Playlist
//
//  Created by Logan Pratt on 7/17/15.
//  Copyright (c) 2015 Logan Pratt. All rights reserved.
//

import UIKit
import SwiftyJSON
//import Parse
/*import Crashlytics*/
import Alamofire

class SearchViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @objc var songSearch = ""
    @objc var songTitles: [String] = []
    @objc var songArtists: [String] = []
    @objc var songCovers: [String] = []
    @objc var songIds: [String] = []
    @objc var groupCode = ""
    var songs: [Song] = []
    @objc let apikey = "AIzaSyCwyQdce6OAUCXH_AEGSlkMIsG60e8BoRc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        searchBar.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        searchBar.becomeFirstResponder()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchSongs(_ song: String) {
        //I think from crashlytics
        //Answers.logSearch(withQuery: song, customAttributes: [:])
        
        songTitles = []
        songArtists = []
        songCovers = []
        songIds = []
        
        let searchUrl = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&q=\(song)&type=video&videoCategoryId=10&key=\(apikey)"
        
        Alamofire.request(searchUrl).responseJSON { (data) -> Void in
            if((data.result.value) != nil) {
                var json = JSON(data.result.value!)
                //print("JSON: \(json)")
                for i in 0..<20 {
                    
                    //if let songArtist = json["items", i, "snippet", "channelTitle"].string {
                    //                    if songArtist.lowercaseString.rangeOfString("vevo") == nil &&
                    //                        songArtist.lowercaseString.rangeOfString("records") == nil &&
                    //                        songArtist.lowercaseString.rangeOfString("nethermight") == nil {
                    //                        if let songDescription = json["items", i, "snippet", "description"].string {
                    //                            if songDescription.lowercaseString.rangeOfString("wmg") == nil &&
                    //                                songDescription.lowercaseString.rangeOfString("umg") == nil &&
                    //                                songDescription.lowercaseString.rangeOfString("sme") == nil {
                    if let songTitle = json["items", i, "snippet", "title"].string {
                        if songTitle.range(of: " - ") != nil {
                            self.songTitles.append(songTitle.components(separatedBy: " - ")[1])
                            self.songArtists.append(songTitle.components(separatedBy: " - ")[0])
                        } else {
                            self.songTitles.append(songTitle)
                            
                            if let songArtist = json["items", 0, "snippet", "channelTitle"].string {
                                self.songArtists.append(songArtist)
                            }
                        }
                    }
                    if let songCover = json["items", i, "snippet", "thumbnails", "high", "url"].string ?? json["items", i, "snippet", "thumbnails", "medium", "url"].string ?? json["items", i, "snippet", "thumbnails", "default", "url"].string{
                        self.songCovers.append(songCover)
                    }
                    if let songId = json["items", i, "id", "videoId"].string {
                        self.songIds.append(songId)
                        
                    }
                    
                    //songArtists.append(songArtist)
                    //                            }
                    //                        }
                    //                    }
                    //}
                    
                    
                }
                self.tableView.reloadData()
            }
        }
        //let data = try? NSURLConnection.sendSynchronousRequest(request, returning: nil)
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
        cell.setUpCell(songCovers[(indexPath as NSIndexPath).row], songTitle: songTitles[(indexPath as NSIndexPath).row], songArtist: songArtists[(indexPath as NSIndexPath).row], songId: songIds[(indexPath as NSIndexPath).row], code: groupCode)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songTitles.count
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        songSearch = searchBar.text!
        songSearch = songSearch.replacingOccurrences(of: " ", with: "+", options: [], range: nil)
        searchBar.endEditing(true)
        searchSongs(songSearch)
    }
}
