//
//  MusicPlayerVC.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/3/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayerVC: UIViewController, SPTAudioStreamingDelegate {
    
    var platformType = -1
    /* Platform meaning:
     0 --- Spotify track clicked
     1 --- Apple Music track clicked
    */
    
    var trackState: Int = -1
    /* trackState:
     -1 --- song has not been played yet
     0 --- song is currently playing
     1 --- song is paused
     */
    
    var player: SPTAudioStreamingController?
    var appleMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    // Track Uri to be used by Spotify
    //var trackUri: String!
    
    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main
    
    // Persisted arrays are always initially filled with unarchived persisted data
    // and used to store/archive data back
    var persistedSpotifyArr = [SpotifyData]()
    var persistedAppleMusicArr = [AppleMusicData]()
    
    // The search results previously filled in the Search View Controller
    var searchResultsSpotifyArr: [SpotifyData] = []
    var searchResultsAppleMusicArr: [AppleMusicData] = []
    
    var selectedIndex: Int = -1
    
    @IBOutlet weak var albumCover: UIImageView!
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unarchive and set respective Spotify or Apple Music persisted array
        // Then set background image, song name, and artist name labels
        // Set up music player (Spotify)
        if platformType == 0 {
            if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: (SpotifyData.ArchiveURL?.path)!) as? [SpotifyData] {
                persistedSpotifyArr = tempArr
            }
            downloadAlbumArtwork(imgUrl: searchResultsSpotifyArr[selectedIndex].artworkUrl)
            songTitle.text = searchResultsSpotifyArr[selectedIndex].songName
            artistTitle.text = searchResultsSpotifyArr[selectedIndex].artistName
            
            //trackUri = searchResultsSpotifyArr[selectedIndex].trackURL
            player = SPTAudioStreamingController.sharedInstance()
            player?.delegate = self
        }
        else {
            if let tempArr = NSKeyedUnarchiver.unarchiveObject(withFile: (AppleMusicData.ArchiveURL?.path)!) as? [AppleMusicData] {
                persistedAppleMusicArr = tempArr
            }
            downloadAlbumArtwork(imgUrl: searchResultsAppleMusicArr[selectedIndex].artworkUrl)
            songTitle.text = searchResultsAppleMusicArr[selectedIndex].songName
            artistTitle.text = searchResultsAppleMusicArr[selectedIndex].artistName
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playMusic(_ sender: UIButton) {
        // Initial playback
        if trackState == -1 {
            // Spotify playing music
            if platformType == 0 {
                player?.playSpotifyURI(searchResultsSpotifyArr[selectedIndex].trackURL, startingWith: 0, startingWithPosition: 0, callback: { error in
                    if error != nil {
                        print("*** failed to play: \(error)")
                        return
                    } else {
                        print("PLAY")
                    }
                })
            }
            // Apple Music playing music
            else {
                appleMusicPlayer.setQueue(with: [searchResultsAppleMusicArr[selectedIndex].trackURL])
                appleMusicPlayer.play()
            }
            //trackState = 0
        }
        // Resume playback
        else if trackState == 1 {
            // Spotify playing music
            if platformType == 0 {
                player?.setIsPlaying(true, callback: nil)
            }
            // Apple Music playing music
            else {
                appleMusicPlayer.play()
            }
            //trackState = 0
        }
        trackState = 0
    }
    
    @IBAction func pauseMusic(_ sender: UIButton) {
        if trackState == 0 {
            // Spotify pausing music
            if platformType == 0 {
                player?.setIsPlaying(false, callback: nil)
            }
            // Apple Music pausing music
            else {
                appleMusicPlayer.pause()
            }
            trackState = 1
        }
    }
    
    @IBAction func restartMusic(_ sender: UIButton) {
        // Spotify restarting music
        if platformType == 0 {
            player?.playSpotifyURI(searchResultsSpotifyArr[selectedIndex].trackURL, startingWith: 0, startingWithPosition: 0, callback: { error in
                if error != nil {
                    print("*** failed to play: \(error)")
                    return
                } else {
                    print("PLAY")
                }
            })
        }
        // Apple Music restarting music
        else {
            appleMusicPlayer.setQueue(with: [searchResultsAppleMusicArr[selectedIndex].trackURL])
            appleMusicPlayer.play()
        }
        trackState = 0;
    }
    
    @IBAction func persistSong(_ sender: UIButton) {
        // Append the selected song and archive it into its respective persisted data
        if platformType == 0 {
            persistedSpotifyArr.append(searchResultsSpotifyArr[selectedIndex])
            NSKeyedArchiver.archiveRootObject(persistedSpotifyArr, toFile: (SpotifyData.ArchiveURL?.path)!)
            showAddedAlert("Song Added!", message: searchResultsSpotifyArr[selectedIndex].songName)
        }
        else {
            persistedAppleMusicArr.append(searchResultsAppleMusicArr[selectedIndex])
            NSKeyedArchiver.archiveRootObject(persistedAppleMusicArr, toFile: (AppleMusicData.ArchiveURL?.path)!)
            showAddedAlert("Song Added!", message: searchResultsAppleMusicArr[selectedIndex].songName)
        }
    }
    
    func showAddedAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func downloadAlbumArtwork(imgUrl: String) {
        ourQueue.addOperation() {
            let url = URL(string: imgUrl)
            let responseData = try? Data(contentsOf: url!)
            let downloadedImage = UIImage(data: responseData!)
            self.mainQueue.addOperation() {
                self.albumCover.image = downloadedImage
                self.background.image = downloadedImage
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
