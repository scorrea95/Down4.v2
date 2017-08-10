//
//  upcomingEventsVC.swift
//  Down4
//
//  Created by amrun on 04/06/17.
//  Copyright © 2017 Digital Hole. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress

class upcomingEventsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionVIew: UICollectionView!
    
    var events = [eventModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchEvents), name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
        fetchEvents()
    }
    
    func fetchEvents() {
        
        events.removeAll()
        DispatchQueue.main.async(execute: {
            self.collectionVIew.reloadData()
        })
        Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/attendingEvents").observe(.childAdded, with: { (snapshot) in
            
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
        
//        cell.option.layer.setValue(indexPath.row, forKey: "index")
//        cell.option.addTarget(self, action: #selector(self.optionPressed(sender:)), for: .touchUpInside)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventDetailVC") as! EventDetailVC
        vc.events = events[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
//    func optionPressed(sender:UIButton) {
//        
//        let row = (sender.layer.value(forKey: "index")) as! Int
//        
//            let alert = UIAlertController.init(title: "Please Select an option", message: nil, preferredStyle: .actionSheet)
//            let action1 = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
//                
//                let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: UIAlertControllerStyle.alert)
//                
//                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//                    
//                    KVNProgress.show()
//                    
//                    Database.database().reference().child("events/\(self.events[row].key!)").removeValue(completionBlock: { (error, refer) in
//                        if error != nil {
//                            print(error!)
//                        }else {
//                            
//                            print(refer)
//                            Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/eventPost/\(self.events[row].key!)").removeValue()
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "fetchpost"), object: nil)
//                            KVNProgress.dismiss()
//                            
//                        }
//                    })
//                    
//                }))
//                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//            let action2 = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in }
//            alert.addAction(action1)
//            alert.addAction(action2)
//            
//            self.present(alert, animated: true, completion: nil)
//    }

    @IBAction func unwindToEvent(segue: UIStoryboardSegue) {}
    
}
