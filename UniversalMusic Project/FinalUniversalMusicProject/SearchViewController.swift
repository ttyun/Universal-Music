//
//  SearchViewController.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/2/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // section titles
    let sections = ["Spotify", "Apple Music"]
    
    // Spotify and Apple Music arrays that contain all relevant data
    var spotifyDataArr = [SpotifyData]()
    var appleMusicDataArr = [AppleMusicData]()
    
    // Spotify base URL to request json data
    var baseSpotifyURL: String = "https://api.spotify.com/v1/search?q="
    
    var searchText: String = ""
    var searchType: String = "track"
    
    // Boolean to determine if search bar is in use or not
    var searching: Bool = false
    
    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main
    
    @IBOutlet weak var searchResultsTable: UITableView!
    
    @IBAction func unwindSearchedSong(segue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searching = false
        DispatchQueue.main.async {
            self.searchResultsTable.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        
        // Clear both data arrays when search is made
        spotifyDataArr.removeAll()
        appleMusicDataArr.removeAll()
        
        // prepare track to be searched
        let search = searchBar.text!
        searchText = search.replacingOccurrences(of: " ", with: "+")
        searching = true
        
        // search Spotify and Apple Music for specified track
        searchSpotifyByTrack(searchString: searchText)
        searchAppleMusicByTrack(searchString: searchText)
    }

    func searchSpotifyByTrack(searchString: String) {
        
        let oAuthToken = (appDelegate.auth?.session?.accessToken)!
        
        let authorizeHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(oAuthToken)",
            "Accept": "application/json"
        ]
        
        
        Alamofire.request(baseSpotifyURL + searchText + "&type=" + searchType + "&limit=10", headers: authorizeHeaders).responseJSON { response in
            if let JSON = response.result.value {
                self.parseSpotifyData(json: JSON as! [String:AnyObject])
                print("\(JSON)")
            }
        }
    }
    
    func parseSpotifyData(json: [String:AnyObject]) {
        let tracks = json["tracks"] as? [String:AnyObject]
        if tracks != nil {
            if let items = tracks?["items"] as? [[String:Any]] {
                let numItems = items.count 
                // loop through json file and get each search entries data
                for i in 0..<numItems {
                    let item = items[i] 
                    
                    let songName = item["name"] as! String
                    
                    let album = item["album"] as! [String:Any]
                    let albumName = album["name"] as! String
                    
                    let artists = album["artists"] as! [[String:Any]]
                    let artist = artists[0] 
                    let artistName = artist["name"] as! String
                    let artistId = artist["id"] as! String
                    
                    let images = album["images"] as! [[String:Any]]
                    let image = images[0] 
                    let artworkUrl = image["url"] as! String
                    
                    let trackUrl = item["uri"] as! String
                    
                    /*print()
                    print("Song: " + songName)
                    print("Artist: " + artistName)
                    print("Album: " + albumName)
                    print("artworkUrl: " + artworkUrl)*/
                    
                    spotifyDataArr.append(SpotifyData(songName, artistName, albumName, artworkUrl, trackUrl, artistId))
                }
                DispatchQueue.main.async {
                    self.searchResultsTable.reloadData()
                }
            }
        }
    }
    
    func searchAppleMusicByTrack(searchString: String) {
        Alamofire.request("https://itunes.apple.com/search?term=\(searchString)&entity=song&limit=10").responseJSON { response in
            if let JSON = response.result.value {
                self.parseAppleMusicData(json: JSON as! [String:AnyObject])
            }
        }
    }
    
    func parseAppleMusicData(json: [String:AnyObject]) {
        let results = json["results"] as? [[String:AnyObject]]
        if results != nil {
            for i in 0..<(results?.count)! {
                var song = (results?[i])! as [String:AnyObject]
                
                let trackName = song["trackName"] as! String
                let artistName = song["artistName"] as! String
                let artwork = song["artworkUrl100"] as! String
                let albumName = song["collectionName"] as! String
                let trackId = song["trackId"] as! Int
                let artistId = song["artistId"] as! Int
                
                appleMusicDataArr.append(AppleMusicData(trackName, artistName, albumName, artwork, "\(trackId)", "\(artistId)"))
            }
            DispatchQueue.main.async {
                self.searchResultsTable.reloadData()
            }
        }
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
    
    // MARK - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching == true {
            if section == 0 {
                return spotifyDataArr.count
            }
            else {
                return appleMusicDataArr.count
            }
        }
        else {
            spotifyDataArr.removeAll()
            appleMusicDataArr.removeAll()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTVCell
        
        // Fill the first section with Spotify Data
        if indexPath.section == 0 {
            let searchedItemSpotify = spotifyDataArr[(indexPath as NSIndexPath).row] 
            downloadAlbumArtwork(imgUrl: searchedItemSpotify.artworkUrl, imageView: cell.albumArtwork)
            cell.songLabel.text = searchedItemSpotify.songName
            cell.artistLabel.text = searchedItemSpotify.artistName
        }
        // Fill the second section with Apple Music Data
        else {
            let searchedItemAppleMusic = appleMusicDataArr[(indexPath as NSIndexPath).row] 
            downloadAlbumArtwork(imgUrl: searchedItemAppleMusic.artworkUrl, imageView: cell.albumArtwork)
            cell.songLabel.text = searchedItemAppleMusic.songName
            cell.artistLabel.text = searchedItemAppleMusic.artistName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searching == true {
            return self.sections.count
        }
        else {
            return 0
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "playSong" {
            let destVC = segue.destination as! MusicPlayerVC
            let selectedIndex = searchResultsTable.indexPathForSelectedRow?.row
            let selectedSection = searchResultsTable.indexPathForSelectedRow?.section
            
            if selectedSection == 0 {
                destVC.searchResultsSpotifyArr = spotifyDataArr
            }
            else {
                destVC.searchResultsAppleMusicArr = appleMusicDataArr
            }
            destVC.selectedIndex = selectedIndex!
            destVC.platformType = selectedSection!
        }
    }
}
