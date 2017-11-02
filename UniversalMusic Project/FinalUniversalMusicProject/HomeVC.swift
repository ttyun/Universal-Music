//
//  HomeVC.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/16/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var spotifyTopSongsTable: UITableView!
    
    var sections = ["Spotify", "Apple Music"]
    
    var spotifyTopFiveArr: [SpotifyData] = []
    var appleMusicTopFiveArr: [AppleMusicData] = []
    
    var spotifyTopHitsUrl = "https://api.spotify.com/v1/users/spotify/playlists/5FJXhjdILmRA2z5bvz4nzf/tracks?market=US&limit=5"
    var appleMusicTopHitsUrl = "https://itunes.apple.com/us/rss/topsongs/limit=5/json"
    
    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main

    var appleMusicSong: AppleMusicData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //while appDelegate.authenticationDone == false {
            
        //}
        self.searchSpotifyPlaylistTopHits()
        self.getAppleMusicTopFiveData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadAlbumArtwork(imgUrl: String, imageView: UIImageView) {
        ourQueue.addOperation() {
            let url = URL(string: imgUrl)
            let responseData = try? Data(contentsOf: url!)
            let downloadedImage = UIImage(data: responseData!)
            self.mainQueue.addOperation() {
                imageView.image = downloadedImage
            }
        }
    }
    
    func searchSpotifyPlaylistTopHits() {
        let oAuthToken = (appDelegate.auth?.session?.accessToken)!
        
        let authorizeHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(oAuthToken)",
            "Accept": "application/json"
        ]
        Alamofire.request(spotifyTopHitsUrl, headers: authorizeHeaders).responseJSON { response in
            if let JSON = response.result.value {
                self.parseSpotifyTopHitsData(json: JSON as AnyObject)
            }
        }
    }
    
    func parseSpotifyTopHitsData(json: AnyObject) {
        let items = json["items"] as! [[String:Any]]
        
        for item in items {
            let track = item["track"] as! [String:Any]
            let songName = track["name"] as! String
            let songUri = track["uri"] as! String
            
            let album = track["album"] as! [String:Any]
            let albumName = album["name"] as! String
            //print(albumName)
            
            let artists = album["artists"] as! [[String:Any]]
            let artist = artists[0] 
            let artistName = artist["name"] as! String
            let artistId = artist["id"] as! String
            
            let images = album["images"] as! [[String:Any]]
            let image = images[0] 
            let artworkUrl = image["url"] as! String
            //print(artworkUrl)
            
            spotifyTopFiveArr.append(SpotifyData(songName, artistName, albumName, artworkUrl, songUri, artistId))
        }
        DispatchQueue.main.async {
            self.spotifyTopSongsTable.reloadData()
        }
    }
    
    func getAppleMusicTopFiveData() {
        var songName : String?
        var artistName : String?
        var songId : String?
        var imageLink : String?
        
        Alamofire.request(appleMusicTopHitsUrl).responseJSON { (responseData) -> Void in
            if ((responseData.result.value!) != nil) {
                let myJson = JSON(responseData.result.value!)
                for entry in myJson["feed"]["entry"].arrayValue {
                    songName = entry["im:name"]["label"].stringValue;
                    songId = entry["id"]["attributes"]["im:id"].stringValue
                    imageLink = entry["im:image"]["label"].stringValue
                    artistName = entry["im:artist"]["label"].stringValue
                    for moreLinks in entry["im:image"].arrayValue {
                        imageLink = moreLinks["label"].stringValue
                        
                        self.appleMusicSong = AppleMusicData(songName!, artistName!, "", imageLink!, songId!, "")
                    }
                    self.appleMusicTopFiveArr.append(self.appleMusicSong!)
                }
                
                DispatchQueue.main.async {
                    self.spotifyTopSongsTable.reloadData()
                }
            }
        }
    }

    // MARK - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return spotifyTopFiveArr.count
        }
        else {
            return appleMusicTopFiveArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotifyTopSongsCell", for: indexPath) as! HomeTVCell
        if indexPath.section == 0 {
            let topSongItem = spotifyTopFiveArr[(indexPath as NSIndexPath).row]
        
            downloadAlbumArtwork(imgUrl: topSongItem.artworkUrl, imageView: cell.albumCoverImg)
            cell.songNameLabel.text = topSongItem.songName
            cell.artistNameLabel.text = topSongItem.artistName
        }
        else {
            let topSongItem = appleMusicTopFiveArr[(indexPath as NSIndexPath).row]
            
            downloadAlbumArtwork(imgUrl: topSongItem.artworkUrl, imageView: cell.albumCoverImg)
            cell.songNameLabel.text = topSongItem.songName
            cell.artistNameLabel.text = topSongItem.artistName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "playTopSongFromHome" {
            let destVC = segue.destination as! MusicPlayerVC
            let selectedIndex = spotifyTopSongsTable.indexPathForSelectedRow?.row
            let selectedSection = spotifyTopSongsTable.indexPathForSelectedRow?.section

            if selectedSection == 0 {
                destVC.searchResultsSpotifyArr = spotifyTopFiveArr
            }
            else {
                destVC.searchResultsAppleMusicArr = appleMusicTopFiveArr
            }
            destVC.selectedIndex = selectedIndex!
            destVC.platformType = selectedSection!
        }
    }

}
