//
//  EventCollectionCell.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit

class EventCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var guestCount: UILabel!
    @IBOutlet weak var EventTitle: UILabel!
    @IBOutlet weak var EventPlace: UILabel!
    @IBOutlet weak var EventDateTime: UILabel!
    @IBOutlet weak var EventCost: UILabel!
    @IBOutlet weak var cloutCount: UILabel!
    @IBOutlet weak var option: UIButton!
    @IBOutlet weak var guestList: UIButton!
}
