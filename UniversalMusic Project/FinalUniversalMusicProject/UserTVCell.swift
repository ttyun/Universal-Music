//
//  UserTVCell.swift
//  FinalUniversalMusicProject
//
//  Created by Tyler Yun on 3/14/17.
//  Copyright © 2017 Tyler Yun. All rights reserved.
//

import UIKit

class UserTVCell: UITableViewCell {
    @IBOutlet weak var artistImg: UIImageView!
    @IBOutlet weak var artistTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
