//
//  User.swift
//  Down4
//
//  Created by steven on 8/9/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import Foundation

class Auser {
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
}

extension Auser {
    static func transformUser(dict: [String: Any], key: String) -> Auser {
        let auser = Auser()
        auser.email = dict["email"] as? String
        auser.profileImageUrl = dict["image"] as? String
        auser.username = dict["username"] as? String
        auser.id = key
        return auser
    }
}
