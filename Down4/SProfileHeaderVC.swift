//
//  SProfileHeaderVC.swift
//  Down4
//
//  Created by amrun on 13/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress

class SProfileHeaderVC: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameage: UILabel!
    @IBOutlet weak var college: UILabel!
    @IBOutlet weak var clout: UILabel!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    
    var userDetails: userItem?
    var userId = ""
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        follow.layer.shadowColor = UIColor.black.cgColor
        follow.layer.shadowOpacity = 0.5
        follow.layer.shadowOffset = CGSize(width: 0, height: 1)
        follow.layer.shadowRadius = 2
        follow.layer.borderWidth = 2
        follow.layer.borderColor = UIColor(red:0.56, green:0.07, blue:1.00, alpha:1.0).cgColor
        follow.layer.cornerRadius = follow.frame.size.height/2
        follow.layer.masksToBounds = false
    //    follow.addTarget(self, action:#selector(self.followPressed), for: .touchUpInside)
       
        fetchUserData()
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchUserData), name: NSNotification.Name(rawValue: "fetchuser"), object: nil)

    }
    
    func fetchUserData() {
        
        
        Database.database().reference().child("users/\(userDetails!.uid!)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            self.userDetails = userItem(dictionary: dictionary)
            self.populateData()
            
        }){(error) in
            
            print(error.localizedDescription)
        }
        
        

    }
    
    //     func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
    //          Database.database().reference().child("following").child(userId).observe(.value, with: {
    //             snapshot in
    //              let count = Int(snapshot.childrenCount)
     //       completion(count)
     //         })
    
     //       }
    
    func populateData() {
        
        checkFollowing()
        
        // Calculate DOB
        let birthday = userDetails?.birthdate!
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .medium
        dateFormater.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let birthdayDate = dateFormater.date(from: birthday!)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let now: NSDate! = NSDate()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now as Date, options: [])
        let age = calcAge.year
        
        nameage.text = "\(userDetails!.fullName!), \(age!)"
    //            username.text = "@\(userDetails!.username!)"
        college.text = userDetails?.college!
        clout.text = "Clout: \(userDetails!.clout!)"
     followerCount.text = "\(userDetails!.followerCount!)"

 
        
        
   //         fetchCountFollowing(userId: userDetails!.uid!) { (count) in
  //               self.followingCount.text = "\(userDetails?.followingCount.count)"
  //            }
        
        
        let picture = userDetails?.imageURL!
        let url = URL(string:picture!)
        self.profileImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        
        userModel.username = "@\(userDetails!.username!)"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showTitle"), object: nil)
    }

    @IBAction func reportPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Report \(userDetails!.fullName!)", message: "Are you sure you want report \(userDetails!.fullName!)?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            KVNProgress.show()
            Database.database().reference().child("Reports/\(self.userDetails!.uid!)/\(Auth.auth().currentUser!.uid)").setValue(true) { (error, ref) in
                if error == nil{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        KVNProgress.dismiss()
                        let alert = UIAlertController(title: "Successfully Reported", message: "You have reported \(self.userDetails!.fullName!) successfully.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    
    }
    

    
    func checkFollowing() {
        
        Database.database().reference().child("users/\(self.userDetails!.uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
               if let followers = dictionary["followers"] as? [String : AnyObject] {
                    for (person) in followers {
                        if person.key == Auth.auth().currentUser!.uid {
                            
                            self.follow.setTitle("Following", for: .normal)
                        }
                   }
                }
            }
        })
    }

    
    @IBAction func invitePressed(_ sender: Any) {
        
    }
    
    @IBAction func followPressed(_ sender: Any) {
        
            
           if self.follow.currentTitle == "Follow"{
                KVNProgress.show()
                
        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/following/\(userDetails!.uid!)").setValue(true) { (error, ref) in
                if error == nil{
                        
                Database.database().reference().child("users/\(self.userDetails!.uid!)/followers/\(Auth.auth().currentUser!.uid)").setValue(true) { (error, ref) in
                        if error == nil{
                                
                        Database.database().reference().child("users/\(self.userDetails!.uid!)").observeSingleEvent(of: .value, with: { (snap) in
                                if let prop = snap.value as? [String : AnyObject] {
                                    if let followers = prop["followers"] as? [String : AnyObject] {
                                        let count = followers.count
                                            
                                            Database.database().reference().child("users/\(self.userDetails!.uid!)").updateChildValues(["followersCount" : count])
                                            
                                            KVNProgress.dismiss()
                                            self.follow.setTitle("Following", for: .normal)
                                            
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchuser"), object: nil)
                                            
                                        }else {
                                            
                                            Database.database().reference().child("users/\(self.userDetails!.uid!)").updateChildValues(["followersCount" : 0])
                                            
                                            KVNProgress.dismiss()
                                            self.follow.setTitle("Following", for: .normal)
                                            
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchuser"), object: nil)
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }else{
                KVNProgress.show()
                
                Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/following/\(userDetails!.uid!)").removeValue() { (error, ref) in
                    if error == nil{
                        
                        Database.database().reference().child("users/\(self.userDetails!.uid!)/followers/\(Auth.auth().currentUser!.uid)").removeValue() { (error, ref) in
                            
                            Database.database().reference().child("users/\(self.userDetails!.uid!)").observeSingleEvent(of: .value, with: { (snap) in
                                if let prop = snap.value as? [String : AnyObject] {
                                    if let followers = prop["followers"] as? [String : AnyObject] {
                                        let count = followers.count
                                        
                                        Database.database().reference().child("users/\(self.userDetails!.uid!)").updateChildValues(["followersCount" : count])
                                        
                                        KVNProgress.dismiss()
                                        self.follow.setTitle("Follow", for: .normal)
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchuser"), object: nil)
                                        
                                    }else{
                                        
                                        Database.database().reference().child("users/\(self.userDetails!.uid!)").updateChildValues(["followersCount" : 0])
                                        
                                        KVNProgress.dismiss()
                                        self.follow.setTitle("Follow", for: .normal)
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchuser"), object: nil)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
        
 
    
}
