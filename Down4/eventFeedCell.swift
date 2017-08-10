//
//  eventFeedCell.swift
//  Down4
//
//  Created by amrun on 08/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit

class eventFeedCell: UITableViewCell {
    
    @IBOutlet weak var post: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var option: UIButton!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
