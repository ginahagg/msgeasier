//
//  FriendTableViewCell.swift
//  msgeasier
//
//  Created by Gina Hagg on 5/7/15.
//  Copyright (c) 2015 Gina Hagg. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lastseen: UILabel!
    @IBOutlet weak var friendPhoto: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
