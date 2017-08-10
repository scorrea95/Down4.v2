//
//  userItem.swift
//  Down4
//
//  Created by amrun on 07/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit

class userItem: NSObject {

    var uid: String?
    var imageURL: String?
    var fullName: String?
    var birthdate: String?
    var email: String?
    var password: String?
    var phone: String?
    var gender: String?
    var college: String?
    var location: String?
    var username: String?
    var notiToken: String?
    var City: String?
    var State: String?
    var createdAt: String?
    var latitude: String?
    var longitude: String?
    var clout: Int?
    
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        uid = dictionary["uid"] as? String
        imageURL = dictionary["image"] as? String
        fullName = dictionary["displayName"] as? String
        birthdate = dictionary["DOB"] as? String
        email = dictionary["email"] as? String
        password = dictionary["password"] as? String
        phone = dictionary["Phone"] as? String
        gender = dictionary["Gender"] as? String
        college = dictionary["college"] as? String
        location = dictionary["location"] as? String
        username = dictionary["username"] as? String
        notiToken = dictionary["notiToken"] as? String
        City = dictionary["City"] as? String
        State = dictionary["State"] as? String
        createdAt = dictionary["createdAt"] as? String
        latitude = dictionary["latitude"] as? String
        longitude = dictionary["longitude"] as? String
        clout = dictionary["Clout"] as? Int
    }
}
