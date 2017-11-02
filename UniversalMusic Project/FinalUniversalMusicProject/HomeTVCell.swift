//
//  HomeTVCell.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/16/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit

class HomeTVCell: UITableViewCell {

    @IBOutlet weak var albumCoverImg: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
