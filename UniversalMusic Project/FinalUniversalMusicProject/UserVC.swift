//
//  UserVC.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/7/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import Alamofire

class UserVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main
    
    // Only using Spotify Data to get Related Artists
    var persistedSpotifyArr: [SpotifyData] = []
    var relatedArtistSpotifyArr: [RelatedArtistData] = []
    
    let baseURLSpotify = "https://api.spotify.com/v1/artists/"
    
    @IBOutlet weak var relatedArtistTable: UITableView!

    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Unarchive persisted Spotify data and set it to the persistedSpotifyArr
        if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: (SpotifyData.ArchiveURL?.path)!) as? [SpotifyData] {
            persistedSpotifyArr = tempArr
        }
        
        // if there are no songs in the Spotify array, make the related artists array empty
        if persistedSpotifyArr.count == 0 {
            warningLabel.text = "Please add at least one song for suggestions."
            relatedArtistSpotifyArr = []
            DispatchQueue.main.async {
                self.relatedArtistTable.reloadData()
            }
        }
        // if there are songs in the Spotify array
        else {
            warningLabel.text = "Related Artists"
            relatedArtistSpotifyArr = []
            // loop through each song in your playlist
            for spotifyData in persistedSpotifyArr {
                // generate a random number to get an artist from the related artists array returned
                let randomNum:UInt32 = arc4random_uniform(9)
                requestRelatedArtistsJSON(artistId: spotifyData.artistId, randomNum: Int(randomNum))
            }
            DispatchQueue.main.async {
                self.relatedArtistTable.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func requestRelatedArtistsJSON(artistId: String, randomNum: Int) {
        
        let oAuthToken = (appDelegate.auth?.session?.accessToken)!
        
        let authorizeHeaders: HTTPHeaders = [
            "Authorization": "Bearer \(oAuthToken)",
            "Accept": "application/json"
        ]
        
        Alamofire.request(baseURLSpotify + artistId + "/related-artists", headers: authorizeHeaders).responseJSON { response in
            if let JSON = response.result.value {
                self.parseRelatedArtistsData(json: JSON as AnyObject, randIndex: randomNum)
                print("\(JSON)");
            }
        }
    }
    
    func parseRelatedArtistsData(json: AnyObject, randIndex: Int) {
        let artistsArr = json["artists"] as! [[String:Any]]
        let artistWanted = artistsArr[randIndex] 
        
        let artistName = artistWanted["name"] as! String
        let artistId = artistWanted["id"] as! String
        let artistImages = artistWanted["images"] as! [[String:Any]]
        let artistImageURL = artistImages[0]["url"] as! String
        
        relatedArtistSpotifyArr.append(RelatedArtistData(artistName, artistId, artistImageURL))
        
        DispatchQueue.main.async {
            self.relatedArtistTable.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return relatedArtistSpotifyArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "relatedArtistCell", for: indexPath) as! UserTVCell
        let relatedArtistObject = relatedArtistSpotifyArr[indexPath.row]
        
        // Configure the cell...
        downloadAlbumArtwork(imgUrl: relatedArtistObject.artistCoverUrl, imageView: cell.artistImg)
        cell.artistTitle.text = relatedArtistObject.artistName
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showRelatedTracks" {
            let destVC = segue.destination as! ArtistTracksTVC
            let selectedIndex = relatedArtistTable.indexPathForSelectedRow?.row
            
            // send the selected related artist's ID to get the artist's top tracks
            destVC.artistId = relatedArtistSpotifyArr[selectedIndex!].artistId
        }
    }

}
