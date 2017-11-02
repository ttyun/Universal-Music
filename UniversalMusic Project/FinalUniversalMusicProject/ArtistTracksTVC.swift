//
//  ArtistTracksTVC.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/14/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import Alamofire

class ArtistTracksTVC: UITableViewController {

    var artistTopTracksArr: [SpotifyData] = []
    var artistId: String = ""
    
    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main

    let baseURL = "https://api.spotify.com/v1/artists/"
    @IBOutlet var relatedSongsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        requestArtistTopTracksJSON(artistId: artistId)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestArtistTopTracksJSON(artistId: String) {
        
        let oAuthToken = (appDelegate.auth?.session?.accessToken)!
        
        let authorizeHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(oAuthToken)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(baseURL + artistId + "/top-tracks?country=US", headers: authorizeHeaders).responseJSON { response in
            if let JSON = response.result.value {
                self.parseArtistTopTrackData(json: JSON as AnyObject)
            }
        }
    }
    
    func parseArtistTopTrackData(json: AnyObject) {
        let tracksArr = json["tracks"] as! [[String:Any]]
        
        for track in tracksArr {
            let songName = track["name"] as! String
            let songUri = track["uri"] as! String
            
            let album = track["album"] as! [String:Any]
            let albumName = album["name"] as! String
            
            let artists = album["artists"] as! [[String:Any]]
            let artist = artists[0] 
            let artistName = artist["name"] as! String
            let artistId = artist["id"] as! String
            
            let images = album["images"] as! [[String:Any]]
            let image = images[0] 
            let artworkUrl = image["url"] as! String
            
            artistTopTracksArr.append(SpotifyData(songName, artistName, albumName, artworkUrl, songUri, artistId))
        }
        DispatchQueue.main.async {
            self.relatedSongsTable.reloadData()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return artistTopTracksArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistTracksCell", for: indexPath) as! ArtistTracksTVCell

        // Configure the cell...
        let songObject = artistTopTracksArr[indexPath.row]
        
        downloadAlbumArtwork(imgUrl: songObject.artworkUrl, imageView: cell.albumCover)
        cell.songName.text = songObject.songName
        cell.artistName.text = songObject.artistName;
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "playArtistTopTrack" {
            let destVC = segue.destination as! MusicPlayerVC
            let selectedIndex = relatedSongsTable.indexPathForSelectedRow?.row
            
            destVC.selectedIndex = selectedIndex!
            destVC.searchResultsSpotifyArr = artistTopTracksArr
            destVC.platformType = 0
        }

    }

}
