//
//  EventDetailVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import KVNProgress

class EventDetailVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var place: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var eventCost: UILabel!
    @IBOutlet weak var detailDateTime: UITextView!
    @IBOutlet weak var detailAddress: UITextView!
    @IBOutlet weak var eventDetail: UITextView!
    @IBOutlet weak var attendButton: UIButton!
    
    var events: eventModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = events?.eventTitle!

        showDetails()
    }
    
    func showDetails() {
        
        checkAttending()
        
        self.eventTitle.text = events?.eventTitle!
        self.place.text = events?.placeName!
        self.dateTime.text = "\(events!.eventDate!) @ \(events!.startTime!)"
        if(events?.eventCost! == "Free"){
            self.eventCost.text = "Free"
        }else{
            self.eventCost.text = "$\(events!.eventCost!)"
        }
        
        self.detailDateTime.text = "\(events!.eventDate!), \(events!.startTime!) - \(events!.endTime!)"
        
        self.detailAddress.text = "\(events!.placeName!)\n\(events!.address!), \(events!.cityandstate!)"
        
        self.eventDetail.text = events?.eventDetail!
        
        image.sd_setImage(with: URL(string: events!.eventImage!), placeholderImage: #imageLiteral(resourceName: "placeholder"))
    }
    
    func checkAttending() {
        
        Database.database().reference().child("events/\(self.events!.key!)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                if let guests = dictionary["guests"] as? [String : AnyObject] {
                    for (person) in guests {
                        if person.key == Auth.auth().currentUser!.uid {
                            
                            self.attendButton.setTitle("ATTENDING", for: .normal)
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func attendPressed(_ sender: Any) {
        
        
        if(events?.eventCost! == "Free"){
            
            if self.attendButton.currentTitle == "ATTEND"{
                KVNProgress.show()
                
                Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/attendingEvents/\(events!.key!)").setValue(true) { (error, ref) in
                    if error == nil{
                        
                        Database.database().reference().child("events/\(self.events!.key!)/guests/\(Auth.auth().currentUser!.uid)").setValue(true) { (error, ref) in
                            if error == nil{
                                
                            Database.database().reference().child("events/\(self.events!.key!)").observeSingleEvent(of: .value, with: { (snap) in
                                if let prop = snap.value as? [String : AnyObject] {
                                    if let guests = prop["guests"] as? [String : AnyObject] {
                                        let count = guests.count
                                        
                                        Database.database().reference().child("events/\(self.events!.key!)").updateChildValues(["guestsCount" : count])
                                        
                                        KVNProgress.dismiss()
                                        self.attendButton.setTitle("ATTENDING", for: .normal)
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)

                                    }else {
                                        
                                        Database.database().reference().child("events/\(self.events!.key!)").updateChildValues(["guestsCount" : 0])
                                        
                                        KVNProgress.dismiss()
                                        self.attendButton.setTitle("ATTENDING", for: .normal)
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                                    }
                                }
                            })
                          }
                        }
                    }
                }
            }else{
                KVNProgress.show()
                
                Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/attendingEvents/\(events!.key!)").removeValue() { (error, ref) in
                    if error == nil{
                        
                        Database.database().reference().child("events/\(self.events!.key!)/guests/\(Auth.auth().currentUser!.uid)").removeValue() { (error, ref) in
                            
                            Database.database().reference().child("events/\(self.events!.key!)").observeSingleEvent(of: .value, with: { (snap) in
                                if let prop = snap.value as? [String : AnyObject] {
                                    if let guests = prop["guests"] as? [String : AnyObject] {
                                        let count = guests.count
                                        
                                        Database.database().reference().child("events/\(self.events!.key!)").updateChildValues(["guestsCount" : count])
                                        
                                        KVNProgress.dismiss()
                                        self.attendButton.setTitle("ATTEND", for: .normal)
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                                        
                                    }else{
                                        
                                        Database.database().reference().child("events/\(self.events!.key!)").updateChildValues(["guestsCount" : 0])
                                        
                                        KVNProgress.dismiss()
                                        self.attendButton.setTitle("ATTEND", for: .normal)
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "paymentNav")
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func invitePressed(_ sender: Any) {
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
    
        // Hide the navigation bar on the this view controller
//                self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = .clear
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        // Show the navigation bar on other view controllers
//               self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }

//    @IBAction func goBack(_ sender: Any) {
//        self.performSegue(withIdentifier: "unwindToEvent", sender: self)
//    }
}
