//
//  RelatedArtistData.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/14/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit

class RelatedArtistData: NSObject {
    var artistName: String
    var artistId: String
    var artistCoverUrl: String
    
    init(_ artist: String, _ id: String, _ cover: String) {
        artistName = artist
        artistId = id
        artistCoverUrl = cover
    }
}
