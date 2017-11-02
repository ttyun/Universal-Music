//
//  ArtistTracksTVCell.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/14/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit

class ArtistTracksTVCell: UITableViewCell {

    @IBOutlet weak var albumCover: UIImageView!
    
    @IBOutlet weak var songName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
