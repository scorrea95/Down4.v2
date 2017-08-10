//
//  eventModel.swift
//  Down4
//
//  Created by amrun on 07/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit

class eventModel: NSObject {
    
    var eventTitle: String?
    var startTime: String?
    var endTime: String?
    var eventDate: String?
    var placeName: String?
    var address: String?
    var cityandstate: String?
    var eventCost: String?
    var eventDetail: String?
    var category: String?
    var createdAt: String?
    var eventImage: String?
    var key: String?
    var uid: String?
    var isPublic: Bool?
    var guestsCount: Int?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        eventTitle = dictionary["eventTitle"] as? String
        startTime = dictionary["startTime"] as? String
        endTime = dictionary["endTime"] as? String
        eventDate = dictionary["eventDate"] as? String
        placeName = dictionary["placeName"] as? String
        address = dictionary["address"] as? String
        cityandstate = dictionary["cityandstate"] as? String
        eventCost = dictionary["eventCost"] as? String
        eventDetail = dictionary["eventDetail"] as? String
        category = dictionary["category"] as? String
        createdAt = dictionary["createdAt"] as? String
        eventImage = dictionary["eventImage"] as? String
        key = dictionary["key"] as? String
        uid = dictionary["uid"] as? String
        isPublic = dictionary["isPublic"] as? Bool
        guestsCount = dictionary["guestsCount"] as? Int
    }
}
