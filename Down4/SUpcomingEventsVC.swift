//
//  SUpcomingEventsVC.swift
//  Down4
//
//  Created by amrun on 13/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress

class SUpcomingEventsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionVIew: UICollectionView!
    
    var events = [eventModel]()
    var userDetails: userItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchEvents), name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
        fetchEvents()
    }

    func fetchEvents() {
        
        events.removeAll()
        DispatchQueue.main.async(execute: {
            self.collectionVIew.reloadData()
        })
        Database.database().reference().child("users/\(userDetails!.uid!)/attendingEvents").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            
            Database.database().reference().child("events/\(key)").observeSingleEvent(of: .value, with: {(snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                self.events.append(eventModel(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    self.events.sort(by: {$0.createdAt! > $1.createdAt!})
                    self.collectionVIew.reloadData()
                    
                    print(dictionary)
                    
                })
            }){(error) in
                
                print(error.localizedDescription)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if events.count > 0 {
            
            collectionVIew.backgroundView = UIImageView(image: nil)
            return self.events.count
            
        }else{
            
            collectionVIew.backgroundView = UIImageView(image: #imageLiteral(resourceName: "noupcomingevents"))
            collectionVIew.backgroundView?.contentMode = .scaleAspectFill
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EventCollectionCell
        
        cell.EventTitle.text = events[indexPath.row].eventTitle
        
        cell.EventPlace.text = events[indexPath.row].placeName
        
        if(events[indexPath.row].eventCost! == "Free"){
            cell.EventCost.text = "Free"
        }else{
            cell.EventCost.text = "$\(events[indexPath.row].eventCost!)"
        }
        
        let date = events[indexPath.row].eventDate
        let time = events[indexPath.row].startTime
        cell.EventDateTime.text = "\(date!) @ \(time!)"
        
        let picture = events[indexPath.row].eventImage
        let url = URL(string:picture!)
        cell.eventImage!.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventDetailVC") as! EventDetailVC
        vc.events = events[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
