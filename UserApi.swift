//
//  UserApi.swift
//  Down4
//
//  Created by steven on 8/9/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class UserApi {
    var REF_USERS = Database.database().reference().child("users")
    
    func observeUserByUsername(username: String, completion: @escaping (Auser) -> Void) {
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: {
            snapshot in
            print(snapshot)
            if let dict = snapshot.value as? [String: Any] {
                let auser = Auser.transformUser(dict: dict, key: snapshot.key)
                completion(auser)
            }
        })
    }
    //                DataService.dataService.USER_REF.queryOrdered(byChild: "username").queryEqual(toValue: "\(mention.lowercased())").observe(.childAdded, with: { snapshot in
    
    func observeUser(withId uid: String, completion: @escaping (Auser) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let auser = Auser.transformUser(dict: dict, key: snapshot.key)
                completion(auser)
            }
        })
    }
    
    func observeCurrentUser(completion: @escaping (Auser) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let auser = Auser.transformUser(dict: dict, key: snapshot.key)
                completion(auser)
            }
        })
    }
    
    func observeUsers(completion: @escaping (Auser) -> Void) {
        REF_USERS.observe(.childAdded, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let auser = Auser.transformUser(dict: dict, key: snapshot.key)
                completion(auser)
            }
        })
    }
    
    func queryUsers(withText text: String, completion: @escaping (Auser) -> Void) {
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let auser = Auser.transformUser(dict: dict, key: child.key)
                    completion(auser)
                }
            })
        })
    }
    
  //  var CURRENT_USER: User? {
  //      if let currentUser = Auth.auth().currentUser {
  //          return currentUser
  //      }
  //          return nil
  //  }
    let CURRENT_USER = Auth.auth().currentUser
    
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        return REF_USERS.child(currentUser.uid)
    }
}
