//
//  profileHeaderVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase

class profileHeaderVC: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameage: UILabel!
//    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var college: UILabel!
    @IBOutlet weak var clout: UILabel!
    @IBOutlet weak var follow: UIButton!

    var userDetails: userItem?
    
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
//        follow.addTarget(self, action:#selector(self.followPressed), for: .touchUpInside)
        
        fetchUserData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchUserData), name: NSNotification.Name(rawValue: "fetchuser"), object: nil)
    }
    
    func fetchUserData() {
        
        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            self.userDetails = userItem(dictionary: dictionary)
            self.populateData()
            
        }){(error) in
            
            print(error.localizedDescription)
        }
    }
    
    func populateData() {
        
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
//        username.text = "@\(userDetails!.username!)"
        college.text = userDetails?.college!
        clout.text = "Clout: \(userDetails!.clout!)"
        
        let picture = userDetails?.imageURL!
        let url = URL(string:picture!)
        self.profileImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        
        userModel.username = "@\(userDetails!.username!)"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showTitle"), object: nil)
    }

    @IBAction func settingsPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "settingsVC") as! settingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func createEventPressed(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "createEventNav")
        self.present(vc, animated: true, completion: nil)

    }
    
    @IBAction func editProfile(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
   
}
