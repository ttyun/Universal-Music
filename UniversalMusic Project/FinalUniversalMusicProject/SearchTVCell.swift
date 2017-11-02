//
//  SearchTVCell.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/2/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit

class SearchTVCell: UITableViewCell {

    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
