//
//  FriendTableViewCell.swift
//  msgeasier
//
//  Created by Gina Hagg on 5/7/15.
//  Copyright (c) 2015 Gina Hagg. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var lastSeen: UILabel!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var friendPhoto: UIImageView!
    
    var messageItem: MessageItem?{
        didSet{
            if let item = messageItem{
                self.friendName.text = item.name
                self.lastSeen.text = item.lastSeen.description
                self.message.text = item.msg
                if let img = item.photo{
                    //println("image is not null \(img)")
                    //self.friendPhoto = UIImageView(image:img)
                    self.friendPhoto.image = img
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
