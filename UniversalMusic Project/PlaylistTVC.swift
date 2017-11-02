//
//  PlaylistTVC.swift
//  
//
//  Created by Tyler Yun on 3/3/17.
//
//

import UIKit

class PlaylistTVC: UITableViewController {

    @IBOutlet var playlistTable: UITableView!
    
    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main
    
    var persistedSpotifyArr: [SpotifyData] = []
    var persistedAppleMusicArr: [AppleMusicData] = []
    
    var sections = ["Spotify", "Apple Music"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: (SpotifyData.ArchiveURL?.path)!) as? [SpotifyData] {
            persistedSpotifyArr = tempArr
        }
        
        if let temp2Arr = NSKeyedUnarchiver.unarchiveObject(withFile: (AppleMusicData.ArchiveURL?.path)!) as? [AppleMusicData] {
            persistedAppleMusicArr = temp2Arr
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: (SpotifyData.ArchiveURL?.path)!) as? [SpotifyData] {
            persistedSpotifyArr = tempArr
        }
        if let temp2Arr = NSKeyedUnarchiver.unarchiveObject(withFile: (AppleMusicData.ArchiveURL?.path)!) as? [AppleMusicData] {
            persistedAppleMusicArr = temp2Arr
        }

        DispatchQueue.main.async {
            self.playlistTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindPlaylistPlayer(segue: UIStoryboardSegue) {
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
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return persistedSpotifyArr.count
        }
        else {
            return persistedAppleMusicArr.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as! PlaylistTVCell
        
        if indexPath.section == 0 {
            let searchedItemSpotify = persistedSpotifyArr[(indexPath as NSIndexPath).row] 
            downloadAlbumArtwork(imgUrl: searchedItemSpotify.artworkUrl, imageView: cell.albumImg)
            cell.songName.text = searchedItemSpotify.songName
            cell.artistName.text = searchedItemSpotify.artistName
        }
        else {
            let searchedItemAppleMusic = persistedAppleMusicArr[(indexPath as NSIndexPath).row] 
            downloadAlbumArtwork(imgUrl: searchedItemAppleMusic.artworkUrl, imageView: cell.albumImg)
            cell.songName.text = searchedItemAppleMusic.songName
            cell.artistName.text = searchedItemAppleMusic.artistName
        }

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            if indexPath.section == 0 {
                persistedSpotifyArr.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                NSKeyedArchiver.archiveRootObject(persistedSpotifyArr, toFile: (SpotifyData.ArchiveURL?.path)!)
            }
            else {
                persistedAppleMusicArr.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                NSKeyedArchiver.archiveRootObject(persistedAppleMusicArr, toFile: (AppleMusicData.ArchiveURL?.path)!)
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

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
        
        if segue.identifier == "playFromPlaylist" {
            let destVC = segue.destination as! PlaylistPlayerVC
            let selectedIndex = playlistTable.indexPathForSelectedRow?.row
            let selectedSection = playlistTable.indexPathForSelectedRow?.section
            
            if selectedSection == 0 {
                destVC.selectedIndex = selectedIndex!
                destVC.playlistSongsArr = persistedSpotifyArr
            }
            else {
                destVC.selectedIndex = selectedIndex!
                destVC.playlistSongsAppleMusicArr = persistedAppleMusicArr
            }
            destVC.platformType = selectedSection!
        }

    }

}
