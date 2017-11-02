//
//  PlaylistPlayerVC.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/7/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlaylistPlayerVC: UIViewController, SPTAudioStreamingDelegate {
    //var audioPlayer = AVAudioPlayer()
    
    var platformType = -1
    /* platform Type:
     0 --- Spotify
     1 --- Apple Music
     */
    
    var player: SPTAudioStreamingController?
    var appleMusicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    var trackUri: String!
    var trackState: Int = -1
    /* trackState:
    -1 --- song has not been played yet
     0 --- song is currently playing
     1 --- song is paused
    */
    
    var ourQueue = OperationQueue()
    var mainQueue = OperationQueue.main

    var playlistSongsArr: [SpotifyData] = []
    var playlistSongsAppleMusicArr: [AppleMusicData] = []
    var selectedIndex: Int = -1
    
    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var background: UIImageView!

    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    @IBAction func playSong(_ sender: UIButton) {
        // start playing/init song
        if trackState == -1 {
            // SPOTIFY
            if platformType == 0 {
                player?.playSpotifyURI(trackUri, startingWith: 0, startingWithPosition: 0, callback: { error in
                    if error != nil {
                        print("*** failed to play: \(error)")
                        return
                    } else {
                        print("PLAY")
                    }
                })
            }
                // APPLE MUSIC
            else {
                appleMusicPlayer.setQueue(with: [playlistSongsAppleMusicArr[selectedIndex].trackURL])
                appleMusicPlayer.play()
            }
            trackState = 0
        }
            // resume playback
        else if trackState == 1 {
            // SPOTIFY
            if platformType == 0 {
                player?.setIsPlaying(true, callback: nil)
            }
                //APPLE MUSIC
            else {
                appleMusicPlayer.play()
            }
            trackState = 0
        }
    }
    
    @IBAction func pauseSong(_ sender: UIButton) {
        if (trackState == 0) {
            // SPOTIFY
            if platformType == 0 {
                player?.setIsPlaying(false, callback: nil)
            }
                // APPLE MUSIC
            else {
                appleMusicPlayer.pause()
            }
            trackState = 1
        }
    }
    
    @IBAction func restartSong(_ sender: UIButton) {
        // SPOTIFY
        if platformType == 0 {
            player?.playSpotifyURI(trackUri, startingWith: 0, startingWithPosition: 0, callback: { error in
                if error != nil {
                    print("*** failed to play: \(error)")
                    return
                } else {
                    print("PLAY")
                }
            })
        }
            // APPLE MUSIC
        else {
            appleMusicPlayer.setQueue(with: [playlistSongsAppleMusicArr[selectedIndex].trackURL])
            appleMusicPlayer.play()
        }
        
        trackState = 0;
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if platformType == 0 {
            downloadAlbumArtwork(imgUrl: playlistSongsArr[selectedIndex].artworkUrl)
            songName.text = playlistSongsArr[selectedIndex].songName
            artistName.text = playlistSongsArr[selectedIndex].artistName
            trackUri = playlistSongsArr[selectedIndex].trackURL
            
            player = SPTAudioStreamingController.sharedInstance()
            player?.delegate = self
        }
        else {
            downloadAlbumArtwork(imgUrl: playlistSongsAppleMusicArr[selectedIndex].artworkUrl)
            songName.text = playlistSongsAppleMusicArr[selectedIndex].songName
            artistName.text = playlistSongsAppleMusicArr[selectedIndex].artistName
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
