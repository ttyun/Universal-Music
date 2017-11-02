//
//  SpotifyData.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/2/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit

class SpotifyData: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
    
    static let ArchiveURL = DocumentsDirectory?.appendingPathComponent("savedSpotifyData")
    
    var songName: String
    var artistName: String
    var albumName: String
    var artworkUrl: String
    //var popularity: Int
    //var elapsedTime: Int
    var trackURL: String
    var artistId: String
    
    init(_ song: String, _ artist: String, _ album: String, _ artwork: String, _ url: String, _ id: String) {
        songName = song
        artistName = artist
        albumName = album
        artworkUrl = artwork
        //popularity = popular
        //elapsedTime = time
        trackURL = url
        artistId = id
    }
    
    required init(coder aDecoder: NSCoder) {
        songName = aDecoder.decodeObject(forKey: "songName") as! String
        artistName = aDecoder.decodeObject(forKey: "artistName") as! String
        albumName = aDecoder.decodeObject(forKey: "albumName") as! String
        artworkUrl = aDecoder.decodeObject(forKey: "artworkUrl") as! String
        //popularity = aDecoder.decodeObject(forKey: "popularity") as! Int
        //elapsedTime = aDecoder.decodeObject(forKey: "elapsedTime") as! Int
        trackURL = aDecoder.decodeObject(forKey: "trackURL") as! String
        artistId = aDecoder.decodeObject(forKey: "artistId") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(songName, forKey: "songName")
        aCoder.encode(artistName, forKey: "artistName")
        aCoder.encode(albumName, forKey: "albumName")
        aCoder.encode(artworkUrl, forKey: "artworkUrl")
        //aCoder.encode(popularity, forKey: "popularity")
        //aCoder.encode(elapsedTime, forKey: "elapsedTime")
        aCoder.encode(trackURL, forKey: "trackURL")
        aCoder.encode(artistId, forKey: "artistId")
    }
}
